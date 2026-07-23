class EnglishLesson {
  final String id;
  final int number;
  final String title;
  final String level;
  final int estimatedMinutes;
  final List<int> sourcePages;
  final String summary;
  final String rawContent;
  final List<String> learningGoals;
  final List<String> practicePrompts;

  const EnglishLesson({
    required this.id,
    required this.number,
    required this.title,
    required this.level,
    required this.estimatedMinutes,
    required this.sourcePages,
    required this.summary,
    required this.rawContent,
    this.learningGoals = const [],
    this.practicePrompts = const [],
  });

  bool get isFirst => number == 1;
  bool get isFinal => number == 36;

  String get paddedNumber => number.toString().padLeft(2, '0');
  String get displayTitle => 'Lección $paddedNumber · $title';
}

EnglishLesson? findEnglishLessonByNumber(
  List<EnglishLesson> lessons,
  int number,
) {
  for (final lesson in lessons) {
    if (lesson.number == number) return lesson;
  }

  return null;
}

EnglishLesson? findEnglishLessonById(
  List<EnglishLesson> lessons,
  String id,
) {
  for (final lesson in lessons) {
    if (lesson.id == id) return lesson;
  }

  return null;
}
