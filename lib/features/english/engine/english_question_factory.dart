import 'dart:math' as math;

import '../data/english_level_1_curriculum.dart';
import '../models/english_activity.dart';
import '../models/english_lesson.dart';
import '../models/english_vocabulary_pair.dart';

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
    // IMPORTANT: nunca inferimos preguntas desde rawContent. El PDF/texto crudo
    // contiene títulos, diálogos partidos y columnas que no son vocabulario.
    // Cada lección solo puede evaluar su banco pedagógico curado.
    return List<EnglishVocabularyPair>.unmodifiable(
      englishLevel1Vocabulary[lesson.number] ?? const [],
    );
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
        conceptKey: pair.english,
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
        conceptKey: pair.english,
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
        conceptKey: pair.english,
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

    if (wordCount <= 8 && pair.english.length <= 72) {
      activities.add(
        EnglishActivity(
          id: 'l${lesson.number}-speak-$key',
          conceptKey: pair.english,
        type: EnglishActivityType.speakAnswer,
          skill: EnglishSkill.speaking,
          difficulty: difficulty,
          prompt: 'Di esta frase en voz alta.',
          instruction: 'Escucha primero y luego repítela. Buscamos claridad, no un acento perfecto.',
          answer: pair.english,
          explanation: 'La frase objetivo era “${pair.english}”.',
          hint: 'Escúchala por bloques y repite sin correr.',
          speechText: pair.english,
          seconds: 45,
          basePoints: 14,
        ),
      );
    }

    final showCorrectTranslation = random.nextBool();
    final shownTranslation = showCorrectTranslation
        ? pair.spanish
        : _differentValue(pair.spanish, spanishPool);
    final tfAnswer = showCorrectTranslation ? 'Verdadero' : 'Falso';

    activities.add(
      EnglishActivity(
        id:
            'l${lesson.number}-tf-$key-${_stableHash(shownTranslation)}',
        conceptKey: pair.english,
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

    if (_supportsStructurePractice(pair.english, words)) {
      activities.add(
        EnglishActivity(
          id: 'l${lesson.number}-order-$key',
          conceptKey: pair.english,
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
          conceptKey: pair.english,
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
          conceptKey: pair.english,
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

    // Solo usamos distractores reales de la MISMA lección. Nunca agregamos
    // respuestas genéricas como “Otra opción”, porque no evalúan inglés.
    final options = <String>[correct, ...unique.take(3)];
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


  bool _supportsStructurePractice(String phrase, List<String> words) {
    if (words.length < 3 || words.length > 9) return false;

    final normalized = phrase.trim().toLowerCase();
    final startsLikeSentence = RegExp(
      r"^(i|you|he|she|it|we|they|what|where|when|how|do|does|is|are|am|have|has|let|good|nice)\b",
    ).hasMatch(normalized);

    // Ordenar/completar se reserva para frases y estructuras. Expresiones
    // nominales cortas como “a university” o “North America” se practican
    // como vocabulario, no como ejercicios gramaticales artificiales.
    return startsLikeSentence || phrase.contains('?') || phrase.contains('!');
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

  int _stableHash(String value) {
    var hash = 2166136261;

    for (final code in value.codeUnits) {
      hash ^= code;
      hash = (hash * 16777619) & 0x7fffffff;
    }

    return hash;
  }

}

