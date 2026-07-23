enum EnglishActivityType {
  multipleChoice,
  trueFalse,
  fillBlank,
  orderWords,
  listenChoice,
  writeAnswer,
}

enum EnglishSkill {
  vocabulary,
  grammar,
  reading,
  listening,
  writing,
  conversation,
}

enum EnglishDifficulty {
  easy,
  medium,
  hard,
}

class EnglishActivity {
  final String id;
  final EnglishActivityType type;
  final EnglishSkill skill;
  final EnglishDifficulty difficulty;
  final String prompt;
  final String instruction;
  final String answer;
  final List<String> acceptedAnswers;
  final List<String> options;
  final List<String> words;
  final String explanation;
  final String hint;
  final String? speechText;
  final int seconds;
  final int basePoints;

  const EnglishActivity({
    required this.id,
    required this.type,
    required this.skill,
    required this.difficulty,
    required this.prompt,
    required this.answer,
    required this.explanation,
    this.instruction = '',
    this.acceptedAnswers = const [],
    this.options = const [],
    this.words = const [],
    this.hint = '',
    this.speechText,
    this.seconds = 30,
    this.basePoints = 10,
  });

  bool get isChoice =>
      type == EnglishActivityType.multipleChoice ||
      type == EnglishActivityType.trueFalse ||
      type == EnglishActivityType.listenChoice;

  bool get needsKeyboard =>
      type == EnglishActivityType.fillBlank ||
      type == EnglishActivityType.writeAnswer;

  List<String> get allAcceptedAnswers => [answer, ...acceptedAnswers];

  EnglishActivity copyWith({
    String? id,
    EnglishActivityType? type,
    EnglishSkill? skill,
    EnglishDifficulty? difficulty,
    String? prompt,
    String? instruction,
    String? answer,
    List<String>? acceptedAnswers,
    List<String>? options,
    List<String>? words,
    String? explanation,
    String? hint,
    String? speechText,
    int? seconds,
    int? basePoints,
  }) {
    return EnglishActivity(
      id: id ?? this.id,
      type: type ?? this.type,
      skill: skill ?? this.skill,
      difficulty: difficulty ?? this.difficulty,
      prompt: prompt ?? this.prompt,
      instruction: instruction ?? this.instruction,
      answer: answer ?? this.answer,
      acceptedAnswers: acceptedAnswers ?? this.acceptedAnswers,
      options: options ?? this.options,
      words: words ?? this.words,
      explanation: explanation ?? this.explanation,
      hint: hint ?? this.hint,
      speechText: speechText ?? this.speechText,
      seconds: seconds ?? this.seconds,
      basePoints: basePoints ?? this.basePoints,
    );
  }
}
