import 'dart:math' as math;

import '../models/english_activity.dart';
import '../models/english_lesson.dart';

class EnglishVocabularyPair {
  final String english;
  final String spanish;

  const EnglishVocabularyPair({
    required this.english,
    required this.spanish,
  });
}

class EnglishQuestionFactory {
  final math.Random random;

  EnglishQuestionFactory({math.Random? random})
      : random = random ?? math.Random.secure();

  List<EnglishActivity> buildPool(EnglishLesson lesson) {
    final pairs = extractPairs(lesson);
    final pool = <EnglishActivity>[];

    final englishPool = pairs.map((item) => item.english).toList();
    final spanishPool = pairs.map((item) => item.spanish).toList();

    for (final pair in pairs) {
      pool.addAll(
        _activitiesForPair(
          lesson: lesson,
          pair: pair,
          englishPool: englishPool,
          spanishPool: spanishPool,
        ),
      );
    }

    pool.addAll(_grammarActivitiesForLesson(lesson));

    final unique = <String, EnglishActivity>{};
    for (final activity in pool) {
      unique[activity.id] = activity;
    }

    return unique.values.toList();
  }

  List<EnglishVocabularyPair> extractPairs(EnglishLesson lesson) {
    final pairs = <EnglishVocabularyPair>[];
    final seen = <String>{};

    void addPair(String english, String spanish) {
      final cleanEnglish = _cleanCell(english);
      final cleanSpanish = _cleanCell(spanish);

      if (!_validPair(cleanEnglish, cleanSpanish)) return;

      final key = '${cleanEnglish.toLowerCase()}|${cleanSpanish.toLowerCase()}';
      if (!seen.add(key)) return;

      pairs.add(
        EnglishVocabularyPair(
          english: cleanEnglish,
          spanish: cleanSpanish,
        ),
      );
    }

    for (final rawLine in lesson.rawContent.split('\n')) {
      final line = rawLine.replaceAll('\t', '    ').trim();
      if (line.isEmpty) continue;

      final columns = line
          .split(RegExp(r'\s{2,}'))
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();

      if (columns.length >= 2) {
        addPair(columns.first, columns.last);
        continue;
      }

      final dash = line.split(RegExp(r'\s[-–—]\s'));
      if (dash.length == 2) {
        final first = dash.first.trim();
        final second = dash.last.trim();

        if (_looksSpanish(first) && !_looksSpanish(second)) {
          addPair(second, first);
        } else {
          addPair(first, second);
        }
      }
    }

    final fallback = _fallbackPairs[lesson.number] ?? const [];
    for (final pair in fallback) {
      addPair(pair.english, pair.spanish);
    }

    if (pairs.length > 42) {
      pairs.shuffle(random);
      return pairs.take(42).toList();
    }

    return pairs;
  }

  List<EnglishActivity> _activitiesForPair({
    required EnglishLesson lesson,
    required EnglishVocabularyPair pair,
    required List<String> englishPool,
    required List<String> spanishPool,
  }) {
    final activities = <EnglishActivity>[];
    final wordCount = _words(pair.english).length;
    final key = _stableHash('${pair.english}|${pair.spanish}');
    final difficulty = wordCount <= 2
        ? EnglishDifficulty.easy
        : wordCount <= 6
            ? EnglishDifficulty.medium
            : EnglishDifficulty.hard;

    activities.add(
      EnglishActivity(
        id: 'l${lesson.number}-en-es-$key',
        type: EnglishActivityType.multipleChoice,
        skill: EnglishSkill.vocabulary,
        difficulty: difficulty,
        prompt: '¿Qué significa “${pair.english}”?',
        instruction: 'Selecciona la traducción correcta.',
        answer: pair.spanish,
        options: _choiceOptions(pair.spanish, spanishPool),
        explanation: '“${pair.english}” significa “${pair.spanish}”.',
        hint: 'Piensa en el contexto principal de la lección.',
        seconds: difficulty == EnglishDifficulty.easy ? 22 : 28,
      ),
    );

    activities.add(
      EnglishActivity(
        id: 'l${lesson.number}-es-en-$key',
        type: EnglishActivityType.multipleChoice,
        skill: EnglishSkill.vocabulary,
        difficulty: difficulty,
        prompt: '¿Cómo se dice “${pair.spanish}” en inglés?',
        instruction: 'Escoge la expresión equivalente.',
        answer: pair.english,
        options: _choiceOptions(pair.english, englishPool),
        explanation: 'La forma correcta es “${pair.english}”.',
        hint: pair.english.isEmpty
            ? ''
            : 'La respuesta comienza por “${pair.english[0].toUpperCase()}”.',
        seconds: difficulty == EnglishDifficulty.easy ? 22 : 28,
      ),
    );

    activities.add(
      EnglishActivity(
        id: 'l${lesson.number}-listen-$key',
        type: EnglishActivityType.listenChoice,
        skill: EnglishSkill.listening,
        difficulty: difficulty,
        prompt: 'Escucha y selecciona el significado.',
        instruction: 'Puedes reproducir el audio más de una vez.',
        answer: pair.spanish,
        options: _choiceOptions(pair.spanish, spanishPool),
        explanation: 'La expresión escuchada fue “${pair.english}”.',
        hint: 'Escucha el ritmo completo antes de responder.',
        speechText: pair.english,
        seconds: difficulty == EnglishDifficulty.hard ? 34 : 28,
      ),
    );

    final showCorrectTranslation = random.nextBool();
    final shownTranslation = showCorrectTranslation
        ? pair.spanish
        : _differentValue(pair.spanish, spanishPool);
    final tfAnswer = showCorrectTranslation ? 'Verdadero' : 'Falso';

    activities.add(
      EnglishActivity(
        id:
            'l${lesson.number}-tf-$key-${_stableHash(shownTranslation)}',
        type: EnglishActivityType.trueFalse,
        skill: EnglishSkill.reading,
        difficulty: difficulty,
        prompt: '“${pair.english}” significa “$shownTranslation”.',
        instruction: 'Decide si la relación es correcta.',
        answer: tfAnswer,
        options: const ['Verdadero', 'Falso'],
        explanation: 'La traducción correcta es “${pair.spanish}”.',
        hint: 'Compara el significado completo, no solo una palabra.',
        seconds: 20,
      ),
    );

    final words = _words(pair.english);

    if (words.length >= 2 && words.length <= 9) {
      activities.add(
        EnglishActivity(
          id: 'l${lesson.number}-order-$key',
          type: EnglishActivityType.orderWords,
          skill: EnglishSkill.grammar,
          difficulty: words.length <= 4
              ? EnglishDifficulty.medium
              : EnglishDifficulty.hard,
          prompt: 'Construye la frase correcta.',
          instruction: 'Ordena todas las palabras.',
          answer: pair.english,
          words: words,
          explanation:
              'El orden correcto es “${pair.english}” y significa “${pair.spanish}”.',
          hint: 'Busca primero la palabra que normalmente inicia la oración.',
          seconds: words.length <= 4 ? 32 : 42,
          basePoints: 12,
        ),
      );

      final blankIndex = _blankIndex(words);
      final missingWord = words[blankIndex];
      final hiddenWords = List<String>.from(words);
      hiddenWords[blankIndex] = '____';

      activities.add(
        EnglishActivity(
          id: 'l${lesson.number}-blank-$key-$blankIndex',
          type: EnglishActivityType.fillBlank,
          skill: EnglishSkill.grammar,
          difficulty: difficulty,
          prompt: hiddenWords.join(' '),
          instruction: 'Escribe la palabra que falta.',
          answer: missingWord,
          explanation:
              'La frase completa es “${pair.english}”.',
          hint: missingWord.isEmpty
              ? ''
              : 'La palabra tiene ${missingWord.length} caracteres y empieza por “${missingWord[0]}”.',
          seconds: 30,
          basePoints: 12,
        ),
      );
    }

    if (pair.english.length <= 62) {
      activities.add(
        EnglishActivity(
          id: 'l${lesson.number}-write-$key',
          type: EnglishActivityType.writeAnswer,
          skill: EnglishSkill.writing,
          difficulty: wordCount <= 3
              ? EnglishDifficulty.medium
              : EnglishDifficulty.hard,
          prompt: 'Escribe en inglés: “${pair.spanish}”',
          instruction: 'No se muestran opciones.',
          answer: pair.english,
          explanation: 'Una respuesta correcta es “${pair.english}”.',
          hint: pair.english.isEmpty
              ? ''
              : 'Empieza por “${pair.english.split(' ').first}”.',
          seconds: wordCount <= 3 ? 34 : 48,
          basePoints: 14,
        ),
      );
    }

    return activities;
  }

  List<EnglishActivity> _grammarActivitiesForLesson(
    EnglishLesson lesson,
  ) {
    final number = lesson.number;
    final result = <EnglishActivity>[];

    void addChoice({
      required String suffix,
      required String prompt,
      required String answer,
      required List<String> options,
      required String explanation,
      EnglishSkill skill = EnglishSkill.grammar,
      EnglishDifficulty difficulty = EnglishDifficulty.medium,
    }) {
      result.add(
        EnglishActivity(
          id: 'l$number-grammar-$suffix',
          type: EnglishActivityType.multipleChoice,
          skill: skill,
          difficulty: difficulty,
          prompt: prompt,
          instruction: 'Selecciona la opción correcta.',
          answer: answer,
          options: List<String>.from(options)..shuffle(random),
          explanation: explanation,
          hint: 'Observa la estructura gramatical de la oración.',
          seconds: difficulty == EnglishDifficulty.hard ? 36 : 28,
          basePoints: 12,
        ),
      );
    }

    switch (number) {
      case 3:
        addChoice(
          suffix: 'pronoun-singular-1',
          prompt: '___ am a student.',
          answer: 'I',
          options: const ['I', 'He', 'She', 'It'],
          explanation: 'Con “am” se utiliza el pronombre “I”.',
        );
        break;
      case 4:
        addChoice(
          suffix: 'pronoun-plural-1',
          prompt: 'Maria and I are friends. ___ study together.',
          answer: 'We',
          options: const ['We', 'They', 'You', 'She'],
          explanation: '“Maria and I” se reemplaza por “we”.',
        );
        break;
      case 5:
      case 6:
        addChoice(
          suffix: 'to-be-1',
          prompt: 'She ___ from Colombia.',
          answer: 'is',
          options: const ['am', 'is', 'are', 'be'],
          explanation: 'Con “she” se utiliza “is”.',
        );
        addChoice(
          suffix: 'to-be-2',
          prompt: 'They ___ not at home.',
          answer: 'are',
          options: const ['am', 'is', 'are', 'be'],
          explanation: 'Con “they” se utiliza “are”.',
        );
        break;
      case 7:
      case 8:
        addChoice(
          suffix: 'numbers-1',
          prompt: 'Which number comes after fourteen?',
          answer: 'Fifteen',
          options: const ['Thirteen', 'Fifteen', 'Sixteen', 'Forty'],
          explanation: 'Después de fourteen viene fifteen.',
          skill: EnglishSkill.vocabulary,
        );
        break;
      case 11:
        addChoice(
          suffix: 'article-1',
          prompt: 'Choose the correct article: ___ apple',
          answer: 'an',
          options: const ['a', 'an', 'the', 'no article'],
          explanation: 'Se usa “an” antes de un sonido vocálico.',
        );
        break;
      case 12:
        addChoice(
          suffix: 'have-1',
          prompt: 'He ___ a new bicycle.',
          answer: 'has',
          options: const ['have', 'has', 'having', 'is have'],
          explanation: 'Con “he” se utiliza “has”.',
        );
        break;
      case 15:
        addChoice(
          suffix: 'time-1',
          prompt: '7:30 is...',
          answer: 'half past seven',
          options: const [
            'half past seven',
            'half past six',
            'quarter to seven',
            'seven o’clock',
          ],
          explanation: '7:30 se expresa “half past seven”.',
        );
        break;
      case 17:
        addChoice(
          suffix: 'comparative-1',
          prompt: 'A train is usually ___ than a bicycle.',
          answer: 'faster',
          options: const ['fast', 'faster', 'fastest', 'more fast'],
          explanation: 'El comparativo de “fast” es “faster”.',
          difficulty: EnglishDifficulty.hard,
        );
        break;
      case 18:
        addChoice(
          suffix: 'countable-1',
          prompt: 'Choose the correct expression: ___ water',
          answer: 'some',
          options: const ['a', 'an', 'some', 'many'],
          explanation: '“Water” es incontable y puede usar “some”.',
        );
        break;
      case 21:
        addChoice(
          suffix: 'simple-present-1',
          prompt: 'She ___ English every day.',
          answer: 'studies',
          options: const ['study', 'studies', 'studying', 'is study'],
          explanation:
              'En presente simple, con “she”, study cambia a “studies”.',
          difficulty: EnglishDifficulty.hard,
        );
        break;
      case 31:
        addChoice(
          suffix: 'present-continuous-1',
          prompt: 'They ___ soccer right now.',
          answer: 'are playing',
          options: const [
            'play',
            'plays',
            'are playing',
            'is playing',
          ],
          explanation:
              '“Right now” indica presente continuo: are + playing.',
          difficulty: EnglishDifficulty.hard,
        );
        break;
      case 32:
        addChoice(
          suffix: 'preposition-1',
          prompt: 'The book is ___ the table.',
          answer: 'on',
          options: const ['on', 'under', 'between', 'behind'],
          explanation: 'Si está encima de la mesa, se utiliza “on”.',
        );
        break;
      case 34:
        addChoice(
          suffix: 'possessive-1',
          prompt: 'I have a dog. ___ name is Max.',
          answer: 'Its',
          options: const ['My', 'His', 'Its', 'Their'],
          explanation: 'Para un animal mencionado como “it”, se usa “its”.',
        );
        break;
      case 36:
        addChoice(
          suffix: 'days-1',
          prompt: 'Which day comes after Wednesday?',
          answer: 'Thursday',
          options: const ['Tuesday', 'Thursday', 'Friday', 'Sunday'],
          explanation: 'Después de Wednesday viene Thursday.',
          skill: EnglishSkill.vocabulary,
        );
        break;
    }

    return result;
  }

  List<String> _choiceOptions(
    String correct,
    List<String> candidates,
  ) {
    final unique = candidates
        .where((item) => item.trim().isNotEmpty && item != correct)
        .toSet()
        .toList()
      ..shuffle(random);

    final options = <String>[correct, ...unique.take(3)];

    while (options.length < 4) {
      final filler = _genericDistractors[options.length - 1];
      if (!options.contains(filler)) options.add(filler);
    }

    options.shuffle(random);
    return options;
  }

  String _differentValue(String correct, List<String> candidates) {
    final alternatives = candidates
        .where((item) => item.trim().isNotEmpty && item != correct)
        .toList()
      ..shuffle(random);

    return alternatives.isEmpty ? 'Una traducción diferente' : alternatives.first;
  }

  int _blankIndex(List<String> words) {
    if (words.length <= 2) return words.length - 1;
    return 1 + random.nextInt(words.length - 1);
  }

  List<String> _words(String phrase) {
    return phrase
        .replaceAll(RegExp(r'[!?.,;:]'), '')
        .split(RegExp(r'\s+'))
        .where((item) => item.trim().isNotEmpty)
        .toList();
  }

  String _cleanCell(String value) {
    return value
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'^[•·*\-–—]+\s*'), '')
        .trim();
  }

  bool _validPair(String english, String spanish) {
    if (english.isEmpty || spanish.isEmpty) return false;
    if (english == spanish) return false;
    if (english.length < 2 || spanish.length < 2) return false;
    if (english.length > 92 || spanish.length > 110) return false;
    if (RegExp(r'^\d+[.)]?$').hasMatch(english)) return false;
    if (RegExp(r'^\d+[.)]?$').hasMatch(spanish)) return false;
    if (_headingLike(english) || _headingLike(spanish)) return false;
    if (!_containsLetter(english) || !_containsLetter(spanish)) return false;

    return true;
  }

  bool _containsLetter(String value) {
    return RegExp(r'[A-Za-zÁÉÍÓÚÜÑáéíóúüñ]').hasMatch(value);
  }

  bool _headingLike(String value) {
    final lower = value.toLowerCase();
    const blocked = [
      'vocabulario y frases',
      'vocabulary and phrases',
      'diálogo',
      'dialogue',
      'lesson',
      'lección',
      'contenido',
    ];

    return blocked.any((item) => lower == item) ||
        lower.startsWith('página ') ||
        lower.startsWith('page ');
  }

  bool _looksSpanish(String value) {
    final lower = value.toLowerCase();
    const markers = [
      ' el ',
      ' la ',
      ' los ',
      ' las ',
      ' de ',
      ' que ',
      ' estoy ',
      ' eres ',
      ' gracias',
      'hola',
      'buenos',
      '¿',
      '¡',
    ];

    return RegExp(r'[áéíóúüñ¿¡]').hasMatch(lower) ||
        markers.any((item) => ' $lower '.contains(item));
  }

  int _stableHash(String value) {
    var hash = 2166136261;

    for (final code in value.codeUnits) {
      hash ^= code;
      hash = (hash * 16777619) & 0x7fffffff;
    }

    return hash;
  }

  static const _genericDistractors = [
    'Otra opción',
    'Ninguna de las anteriores',
    'No corresponde',
  ];
}

const _fallbackPairs = <int, List<EnglishVocabularyPair>>{
  1: [
    EnglishVocabularyPair(english: 'Hello', spanish: 'Hola'),
    EnglishVocabularyPair(english: 'Welcome', spanish: 'Bienvenido'),
    EnglishVocabularyPair(english: 'Good morning', spanish: 'Buenos días'),
    EnglishVocabularyPair(english: 'Nice to meet you', spanish: 'Mucho gusto'),
    EnglishVocabularyPair(english: 'What is your name?', spanish: '¿Cuál es tu nombre?'),
    EnglishVocabularyPair(english: 'Where are you from?', spanish: '¿De dónde eres?'),
  ],
  2: [
    EnglishVocabularyPair(english: 'How are you?', spanish: '¿Cómo estás?'),
    EnglishVocabularyPair(english: 'I am fine', spanish: 'Estoy bien'),
    EnglishVocabularyPair(english: 'I am happy', spanish: 'Estoy feliz'),
    EnglishVocabularyPair(english: 'I am tired', spanish: 'Estoy cansado'),
    EnglishVocabularyPair(english: 'I am worried', spanish: 'Estoy preocupado'),
  ],
  3: [
    EnglishVocabularyPair(english: 'I', spanish: 'Yo'),
    EnglishVocabularyPair(english: 'You', spanish: 'Tú'),
    EnglishVocabularyPair(english: 'He', spanish: 'Él'),
    EnglishVocabularyPair(english: 'She', spanish: 'Ella'),
    EnglishVocabularyPair(english: 'It', spanish: 'Eso'),
  ],
  4: [
    EnglishVocabularyPair(english: 'We', spanish: 'Nosotros'),
    EnglishVocabularyPair(english: 'You', spanish: 'Ustedes'),
    EnglishVocabularyPair(english: 'They', spanish: 'Ellos'),
  ],
  5: [
    EnglishVocabularyPair(english: 'I am', spanish: 'Yo soy / estoy'),
    EnglishVocabularyPair(english: 'You are', spanish: 'Tú eres / estás'),
    EnglishVocabularyPair(english: 'He is', spanish: 'Él es / está'),
    EnglishVocabularyPair(english: 'We are', spanish: 'Nosotros somos / estamos'),
  ],
  6: [
    EnglishVocabularyPair(english: 'I am not', spanish: 'Yo no soy / estoy'),
    EnglishVocabularyPair(english: 'Are you?', spanish: '¿Eres / estás?'),
    EnglishVocabularyPair(english: 'Is she?', spanish: '¿Ella es / está?'),
  ],
  7: [
    EnglishVocabularyPair(english: 'One', spanish: 'Uno'),
    EnglishVocabularyPair(english: 'Two', spanish: 'Dos'),
    EnglishVocabularyPair(english: 'Three', spanish: 'Tres'),
    EnglishVocabularyPair(english: 'Four', spanish: 'Cuatro'),
    EnglishVocabularyPair(english: 'Five', spanish: 'Cinco'),
  ],
  8: [
    EnglishVocabularyPair(english: 'Eleven', spanish: 'Once'),
    EnglishVocabularyPair(english: 'Twelve', spanish: 'Doce'),
    EnglishVocabularyPair(english: 'Fifteen', spanish: 'Quince'),
    EnglishVocabularyPair(english: 'Twenty', spanish: 'Veinte'),
  ],
  9: [
    EnglishVocabularyPair(english: 'Red', spanish: 'Rojo'),
    EnglishVocabularyPair(english: 'Blue', spanish: 'Azul'),
    EnglishVocabularyPair(english: 'Green', spanish: 'Verde'),
    EnglishVocabularyPair(english: 'Yellow', spanish: 'Amarillo'),
    EnglishVocabularyPair(english: 'Black', spanish: 'Negro'),
  ],
  10: [
    EnglishVocabularyPair(english: 'Mother', spanish: 'Madre'),
    EnglishVocabularyPair(english: 'Father', spanish: 'Padre'),
    EnglishVocabularyPair(english: 'Sister', spanish: 'Hermana'),
    EnglishVocabularyPair(english: 'Brother', spanish: 'Hermano'),
    EnglishVocabularyPair(english: 'Grandparents', spanish: 'Abuelos'),
  ],
  11: [
    EnglishVocabularyPair(english: 'a book', spanish: 'un libro'),
    EnglishVocabularyPair(english: 'an apple', spanish: 'una manzana'),
    EnglishVocabularyPair(english: 'a university', spanish: 'una universidad'),
  ],
  12: [
    EnglishVocabularyPair(english: 'I have a car', spanish: 'Tengo un carro'),
    EnglishVocabularyPair(english: 'She has a dog', spanish: 'Ella tiene un perro'),
    EnglishVocabularyPair(english: 'Do you have time?', spanish: '¿Tienes tiempo?'),
  ],
  13: [
    EnglishVocabularyPair(english: 'Tall', spanish: 'Alto'),
    EnglishVocabularyPair(english: 'Short', spanish: 'Bajo'),
    EnglishVocabularyPair(english: 'Young', spanish: 'Joven'),
    EnglishVocabularyPair(english: 'Beautiful', spanish: 'Hermoso'),
  ],
  14: [
    EnglishVocabularyPair(english: 'Head', spanish: 'Cabeza'),
    EnglishVocabularyPair(english: 'Eyes', spanish: 'Ojos'),
    EnglishVocabularyPair(english: 'Hands', spanish: 'Manos'),
    EnglishVocabularyPair(english: 'Feet', spanish: 'Pies'),
  ],
  15: [
    EnglishVocabularyPair(english: 'What time is it?', spanish: '¿Qué hora es?'),
    EnglishVocabularyPair(english: 'It is seven o’clock', spanish: 'Son las siete'),
    EnglishVocabularyPair(english: 'Half past eight', spanish: 'Ocho y media'),
  ],
  16: [
    EnglishVocabularyPair(english: 'Play soccer', spanish: 'Jugar fútbol'),
    EnglishVocabularyPair(english: 'Go swimming', spanish: 'Ir a nadar'),
    EnglishVocabularyPair(english: 'Practice tennis', spanish: 'Practicar tenis'),
  ],
  17: [
    EnglishVocabularyPair(english: 'Bigger than', spanish: 'Más grande que'),
    EnglishVocabularyPair(english: 'The fastest', spanish: 'El más rápido'),
    EnglishVocabularyPair(english: 'More interesting', spanish: 'Más interesante'),
  ],
  18: [
    EnglishVocabularyPair(english: 'Many apples', spanish: 'Muchas manzanas'),
    EnglishVocabularyPair(english: 'Much water', spanish: 'Mucha agua'),
    EnglishVocabularyPair(english: 'A little milk', spanish: 'Un poco de leche'),
  ],
  19: [
    EnglishVocabularyPair(english: 'I wish you luck', spanish: 'Te deseo suerte'),
    EnglishVocabularyPair(english: 'Happy birthday', spanish: 'Feliz cumpleaños'),
    EnglishVocabularyPair(english: 'Congratulations', spanish: 'Felicitaciones'),
  ],
  20: [
    EnglishVocabularyPair(english: 'Dog', spanish: 'Perro'),
    EnglishVocabularyPair(english: 'Cat', spanish: 'Gato'),
    EnglishVocabularyPair(english: 'Bird', spanish: 'Pájaro'),
    EnglishVocabularyPair(english: 'Rabbit', spanish: 'Conejo'),
  ],
  21: [
    EnglishVocabularyPair(english: 'I work every day', spanish: 'Trabajo todos los días'),
    EnglishVocabularyPair(english: 'She studies English', spanish: 'Ella estudia inglés'),
    EnglishVocabularyPair(english: 'They live in Bogotá', spanish: 'Ellos viven en Bogotá'),
  ],
  22: [
    EnglishVocabularyPair(english: 'Spain', spanish: 'España'),
    EnglishVocabularyPair(english: 'France', spanish: 'Francia'),
    EnglishVocabularyPair(english: 'Germany', spanish: 'Alemania'),
    EnglishVocabularyPair(english: 'Italy', spanish: 'Italia'),
  ],
  23: [
    EnglishVocabularyPair(english: 'Have breakfast', spanish: 'Desayunar'),
    EnglishVocabularyPair(english: 'A cup of coffee', spanish: 'Una taza de café'),
    EnglishVocabularyPair(english: 'Toast and eggs', spanish: 'Tostadas y huevos'),
  ],
  24: [
    EnglishVocabularyPair(english: 'Apple', spanish: 'Manzana'),
    EnglishVocabularyPair(english: 'Orange', spanish: 'Naranja'),
    EnglishVocabularyPair(english: 'Strawberry', spanish: 'Fresa'),
    EnglishVocabularyPair(english: 'Watermelon', spanish: 'Sandía'),
  ],
  25: [
    EnglishVocabularyPair(english: 'Carrot', spanish: 'Zanahoria'),
    EnglishVocabularyPair(english: 'Onion', spanish: 'Cebolla'),
    EnglishVocabularyPair(english: 'Tomato', spanish: 'Tomate'),
    EnglishVocabularyPair(english: 'Potato', spanish: 'Papa'),
  ],
  26: [
    EnglishVocabularyPair(english: 'How much is it?', spanish: '¿Cuánto cuesta?'),
    EnglishVocabularyPair(english: 'I would like this one', spanish: 'Quisiera este'),
    EnglishVocabularyPair(english: 'It is too expensive', spanish: 'Es demasiado caro'),
  ],
  27: [
    EnglishVocabularyPair(english: 'What do you do?', spanish: '¿A qué te dedicas?'),
    EnglishVocabularyPair(english: 'I am a teacher', spanish: 'Soy profesor'),
    EnglishVocabularyPair(english: 'I work in an office', spanish: 'Trabajo en una oficina'),
  ],
  28: [
    EnglishVocabularyPair(english: 'North America', spanish: 'Norteamérica'),
    EnglishVocabularyPair(english: 'South America', spanish: 'Sudamérica'),
    EnglishVocabularyPair(english: 'United States', spanish: 'Estados Unidos'),
    EnglishVocabularyPair(english: 'Colombia', spanish: 'Colombia'),
  ],
  29: [
    EnglishVocabularyPair(english: 'Where am I?', spanish: '¿Dónde estoy?'),
    EnglishVocabularyPair(english: 'I am at the bank', spanish: 'Estoy en el banco'),
    EnglishVocabularyPair(english: 'The hospital is nearby', spanish: 'El hospital está cerca'),
  ],
  30: [
    EnglishVocabularyPair(english: 'Bedroom', spanish: 'Habitación'),
    EnglishVocabularyPair(english: 'Living room', spanish: 'Sala'),
    EnglishVocabularyPair(english: 'Bed', spanish: 'Cama'),
    EnglishVocabularyPair(english: 'Sofa', spanish: 'Sofá'),
  ],
  31: [
    EnglishVocabularyPair(english: 'I am reading', spanish: 'Estoy leyendo'),
    EnglishVocabularyPair(english: 'She is cooking', spanish: 'Ella está cocinando'),
    EnglishVocabularyPair(english: 'They are playing', spanish: 'Ellos están jugando'),
  ],
  32: [
    EnglishVocabularyPair(english: 'On the table', spanish: 'Sobre la mesa'),
    EnglishVocabularyPair(english: 'Under the chair', spanish: 'Debajo de la silla'),
    EnglishVocabularyPair(english: 'Next to the door', spanish: 'Al lado de la puerta'),
  ],
  33: [
    EnglishVocabularyPair(english: 'Doctor', spanish: 'Médico'),
    EnglishVocabularyPair(english: 'Engineer', spanish: 'Ingeniero'),
    EnglishVocabularyPair(english: 'Nurse', spanish: 'Enfermero'),
    EnglishVocabularyPair(english: 'Chef', spanish: 'Cocinero'),
  ],
  34: [
    EnglishVocabularyPair(english: 'My house', spanish: 'Mi casa'),
    EnglishVocabularyPair(english: 'Your book', spanish: 'Tu libro'),
    EnglishVocabularyPair(english: 'Her car', spanish: 'El carro de ella'),
    EnglishVocabularyPair(english: 'Their children', spanish: 'Sus hijos'),
  ],
  35: [
    EnglishVocabularyPair(english: 'Small', spanish: 'Pequeño'),
    EnglishVocabularyPair(english: 'Medium', spanish: 'Mediano'),
    EnglishVocabularyPair(english: 'Large', spanish: 'Grande'),
    EnglishVocabularyPair(english: 'Extra large', spanish: 'Extra grande'),
  ],
  36: [
    EnglishVocabularyPair(english: 'Monday', spanish: 'Lunes'),
    EnglishVocabularyPair(english: 'Wednesday', spanish: 'Miércoles'),
    EnglishVocabularyPair(english: 'Friday', spanish: 'Viernes'),
    EnglishVocabularyPair(english: 'What day is today?', spanish: '¿Qué día es hoy?'),
  ],
};
