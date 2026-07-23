import 'english_activity.dart';

class EnglishLearningSession {
  final String id;
  final int lessonNumber;
  final int attempt;
  final EnglishDifficulty targetDifficulty;
  final List<EnglishActivity> activities;
  final DateTime createdAt;

  const EnglishLearningSession({
    required this.id,
    required this.lessonNumber,
    required this.attempt,
    required this.targetDifficulty,
    required this.activities,
    required this.createdAt,
  });

  int get totalBasePoints => activities.fold<int>(
        0,
        (total, activity) => total + activity.basePoints,
      );
}

class EnglishActivityOutcome {
  final String activityId;
  final EnglishSkill skill;
  final EnglishDifficulty difficulty;
  final bool correct;
  final int responseMilliseconds;
  final bool usedHint;

  const EnglishActivityOutcome({
    required this.activityId,
    required this.skill,
    required this.difficulty,
    required this.correct,
    required this.responseMilliseconds,
    required this.usedHint,
  });

  Map<String, dynamic> toJson() {
    return {
      'activityId': activityId,
      'skill': skill.name,
      'difficulty': difficulty.name,
      'correct': correct,
      'responseMilliseconds': responseMilliseconds,
      'usedHint': usedHint,
    };
  }
}

class EnglishSessionResult {
  final String sessionId;
  final int lessonNumber;
  final int score;
  final int xp;
  final int correctAnswers;
  final int totalActivities;
  final int attempts;
  final int maxCombo;
  final int averageResponseMilliseconds;
  final bool passed;
  final List<EnglishActivityOutcome> outcomes;

  const EnglishSessionResult({
    required this.sessionId,
    required this.lessonNumber,
    required this.score,
    required this.xp,
    required this.correctAnswers,
    required this.totalActivities,
    required this.attempts,
    required this.maxCombo,
    required this.averageResponseMilliseconds,
    required this.passed,
    required this.outcomes,
  });

  Map<String, dynamic> toNavigationResult() {
    return {
      'sessionId': sessionId,
      'lessonNumber': lessonNumber,
      'score': score,
      'xp': xp,
      'correctAnswers': correctAnswers,
      'totalActivities': totalActivities,
      'attempts': attempts,
      'maxCombo': maxCombo,
      'averageResponseMilliseconds': averageResponseMilliseconds,
      'passed': passed,
      'outcomes': outcomes.map((item) => item.toJson()).toList(),
    };
  }
}
