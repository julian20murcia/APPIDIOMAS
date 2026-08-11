import '../models/english_activity.dart';

class EnglishLessonActivityProfile {
  final List<EnglishActivityType> practicePattern;
  final List<EnglishActivityType> evaluationPattern;
  final bool prioritizeCoverage;
  final int minimumPracticeItems;
  const EnglishLessonActivityProfile({
    required this.practicePattern,
    required this.evaluationPattern,
    this.prioritizeCoverage = true,
    this.minimumPracticeItems = 10,
  });
}

const _vocab = <EnglishActivityType>[
  EnglishActivityType.listenChoice,
  EnglishActivityType.multipleChoice,
  EnglishActivityType.speakAnswer,
  EnglishActivityType.writeAnswer,
  EnglishActivityType.trueFalse,
  EnglishActivityType.multipleChoice,
];
const _grammar = <EnglishActivityType>[
  EnglishActivityType.multipleChoice,
  EnglishActivityType.fillBlank,
  EnglishActivityType.orderWords,
  EnglishActivityType.listenChoice,
  EnglishActivityType.speakAnswer,
  EnglishActivityType.writeAnswer,
];
const _conversation = <EnglishActivityType>[
  EnglishActivityType.listenChoice,
  EnglishActivityType.speakAnswer,
  EnglishActivityType.multipleChoice,
  EnglishActivityType.orderWords,
  EnglishActivityType.writeAnswer,
  EnglishActivityType.listenChoice,
];
const _visualLexical = <EnglishActivityType>[
  EnglishActivityType.multipleChoice,
  EnglishActivityType.listenChoice,
  EnglishActivityType.trueFalse,
  EnglishActivityType.speakAnswer,
  EnglishActivityType.writeAnswer,
];

const englishLevel1ActivityProfiles = <int, EnglishLessonActivityProfile>{
  1: EnglishLessonActivityProfile(practicePattern:_conversation,evaluationPattern:_conversation),
  2: EnglishLessonActivityProfile(practicePattern:_conversation,evaluationPattern:_conversation),
  3: EnglishLessonActivityProfile(practicePattern:_grammar,evaluationPattern:_grammar),
  4: EnglishLessonActivityProfile(practicePattern:_grammar,evaluationPattern:_grammar),
  5: EnglishLessonActivityProfile(practicePattern:_grammar,evaluationPattern:_grammar),
  6: EnglishLessonActivityProfile(practicePattern:_grammar,evaluationPattern:_grammar),
  7: EnglishLessonActivityProfile(practicePattern:_vocab,evaluationPattern:_vocab,minimumPracticeItems:14),
  8: EnglishLessonActivityProfile(practicePattern:_vocab,evaluationPattern:_vocab,minimumPracticeItems:14),
  9: EnglishLessonActivityProfile(practicePattern:_visualLexical,evaluationPattern:_visualLexical,minimumPracticeItems:14),
  10: EnglishLessonActivityProfile(practicePattern:_visualLexical,evaluationPattern:_conversation,minimumPracticeItems:14),
  11: EnglishLessonActivityProfile(practicePattern:_grammar,evaluationPattern:_grammar),
  12: EnglishLessonActivityProfile(practicePattern:_grammar,evaluationPattern:_grammar),
  13: EnglishLessonActivityProfile(practicePattern:_visualLexical,evaluationPattern:_conversation,minimumPracticeItems:14),
  14: EnglishLessonActivityProfile(practicePattern:_visualLexical,evaluationPattern:_visualLexical,minimumPracticeItems:14),
  15: EnglishLessonActivityProfile(practicePattern:_conversation,evaluationPattern:_conversation,minimumPracticeItems:14),
  16: EnglishLessonActivityProfile(practicePattern:_visualLexical,evaluationPattern:_conversation,minimumPracticeItems:14),
  17: EnglishLessonActivityProfile(practicePattern:_grammar,evaluationPattern:_grammar),
  18: EnglishLessonActivityProfile(practicePattern:_grammar,evaluationPattern:_grammar),
  19: EnglishLessonActivityProfile(practicePattern:_conversation,evaluationPattern:_conversation),
  20: EnglishLessonActivityProfile(practicePattern:_visualLexical,evaluationPattern:_conversation,minimumPracticeItems:14),
  21: EnglishLessonActivityProfile(practicePattern:_grammar,evaluationPattern:_grammar),
  22: EnglishLessonActivityProfile(practicePattern:_visualLexical,evaluationPattern:_conversation,minimumPracticeItems:14),
  23: EnglishLessonActivityProfile(practicePattern:_conversation,evaluationPattern:_conversation,minimumPracticeItems:14),
  24: EnglishLessonActivityProfile(practicePattern:_visualLexical,evaluationPattern:_conversation,minimumPracticeItems:14),
  25: EnglishLessonActivityProfile(practicePattern:_visualLexical,evaluationPattern:_conversation,minimumPracticeItems:14),
  26: EnglishLessonActivityProfile(practicePattern:_conversation,evaluationPattern:_conversation,minimumPracticeItems:14),
  27: EnglishLessonActivityProfile(practicePattern:_conversation,evaluationPattern:_conversation),
  28: EnglishLessonActivityProfile(practicePattern:_visualLexical,evaluationPattern:_conversation,minimumPracticeItems:14),
  29: EnglishLessonActivityProfile(practicePattern:_conversation,evaluationPattern:_conversation,minimumPracticeItems:14),
  30: EnglishLessonActivityProfile(practicePattern:_visualLexical,evaluationPattern:_grammar,minimumPracticeItems:14),
  31: EnglishLessonActivityProfile(practicePattern:_grammar,evaluationPattern:_grammar),
  32: EnglishLessonActivityProfile(practicePattern:_visualLexical,evaluationPattern:_conversation,minimumPracticeItems:14),
  33: EnglishLessonActivityProfile(practicePattern:_visualLexical,evaluationPattern:_conversation,minimumPracticeItems:14),
  34: EnglishLessonActivityProfile(practicePattern:_grammar,evaluationPattern:_grammar),
  35: EnglishLessonActivityProfile(practicePattern:_visualLexical,evaluationPattern:_visualLexical,minimumPracticeItems:14),
  36: EnglishLessonActivityProfile(practicePattern:_vocab,evaluationPattern:_conversation,minimumPracticeItems:14),
};
