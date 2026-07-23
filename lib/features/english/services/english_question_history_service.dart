import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/english_activity.dart';
import '../models/english_learning_session.dart';

class EnglishSkillHistory {
  final int correct;
  final int total;

  const EnglishSkillHistory({
    required this.correct,
    required this.total,
  });

  double get accuracy => total == 0 ? 0 : correct / total;

  EnglishSkillHistory add({required bool wasCorrect}) {
    return EnglishSkillHistory(
      correct: correct + (wasCorrect ? 1 : 0),
      total: total + 1,
    );
  }

  factory EnglishSkillHistory.fromJson(Map<String, dynamic> json) {
    return EnglishSkillHistory(
      correct: (json['correct'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'correct': correct,
      'total': total,
    };
  }
}

class EnglishQuestionHistorySnapshot {
  final List<String> recentQuestionIds;
  final Map<EnglishSkill, EnglishSkillHistory> skillHistory;
  final int sessionsCompleted;

  const EnglishQuestionHistorySnapshot({
    required this.recentQuestionIds,
    required this.skillHistory,
    required this.sessionsCompleted,
  });

  factory EnglishQuestionHistorySnapshot.empty() {
    return const EnglishQuestionHistorySnapshot(
      recentQuestionIds: [],
      skillHistory: {},
      sessionsCompleted: 0,
    );
  }

  double get globalAccuracy {
    final total = skillHistory.values.fold<int>(
      0,
      (sum, item) => sum + item.total,
    );

    if (total == 0) return 0;

    final correct = skillHistory.values.fold<int>(
      0,
      (sum, item) => sum + item.correct,
    );

    return correct / total;
  }

  double accuracyFor(EnglishSkill skill) {
    return skillHistory[skill]?.accuracy ?? 0;
  }

  double weaknessWeight(EnglishSkill skill) {
    final history = skillHistory[skill];

    if (history == null || history.total < 2) return 1.25;

    final weakness = 1 - history.accuracy;
    return 1 + (weakness * 1.8);
  }
}

class EnglishQuestionHistoryService {
  static const int _maxRecentQuestions = 90;

  String _key(int lessonNumber) {
    return 'lingoverse_question_history_lesson_$lessonNumber';
  }

  Future<EnglishQuestionHistorySnapshot> load(int lessonNumber) async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_key(lessonNumber));

    if (raw == null || raw.trim().isEmpty) {
      return EnglishQuestionHistorySnapshot.empty();
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! Map) {
        return EnglishQuestionHistorySnapshot.empty();
      }

      final map = Map<String, dynamic>.from(decoded);
      final recent = (map['recentQuestionIds'] as List?)
              ?.whereType<String>()
              .toList() ??
          <String>[];

      final skillHistory = <EnglishSkill, EnglishSkillHistory>{};
      final rawSkills = map['skillHistory'];

      if (rawSkills is Map) {
        for (final entry in rawSkills.entries) {
          final skill = EnglishSkill.values.where(
            (item) => item.name == entry.key.toString(),
          );

          if (skill.isEmpty || entry.value is! Map) continue;

          skillHistory[skill.first] = EnglishSkillHistory.fromJson(
            Map<String, dynamic>.from(entry.value as Map),
          );
        }
      }

      return EnglishQuestionHistorySnapshot(
        recentQuestionIds: recent,
        skillHistory: skillHistory,
        sessionsCompleted:
            (map['sessionsCompleted'] as num?)?.toInt() ?? 0,
      );
    } catch (_) {
      return EnglishQuestionHistorySnapshot.empty();
    }
  }

  Future<EnglishQuestionHistorySnapshot> recordSession({
    required int lessonNumber,
    required List<EnglishActivityOutcome> outcomes,
  }) async {
    final current = await load(lessonNumber);

    final recent = <String>[
      ...current.recentQuestionIds,
      ...outcomes.map((item) => item.activityId),
    ];

    final deduplicatedRecent = <String>[];

    for (final id in recent.reversed) {
      if (!deduplicatedRecent.contains(id)) {
        deduplicatedRecent.add(id);
      }

      if (deduplicatedRecent.length >= _maxRecentQuestions) break;
    }

    final orderedRecent = deduplicatedRecent.reversed.toList();
    final skills = Map<EnglishSkill, EnglishSkillHistory>.from(
      current.skillHistory,
    );

    for (final outcome in outcomes) {
      final previous = skills[outcome.skill] ??
          const EnglishSkillHistory(correct: 0, total: 0);

      skills[outcome.skill] = previous.add(
        wasCorrect: outcome.correct,
      );
    }

    final snapshot = EnglishQuestionHistorySnapshot(
      recentQuestionIds: orderedRecent,
      skillHistory: skills,
      sessionsCompleted: current.sessionsCompleted + 1,
    );

    await _save(lessonNumber, snapshot);
    return snapshot;
  }

  Future<void> clearLesson(int lessonNumber) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_key(lessonNumber));
  }

  Future<void> _save(
    int lessonNumber,
    EnglishQuestionHistorySnapshot snapshot,
  ) async {
    final preferences = await SharedPreferences.getInstance();

    final payload = {
      'recentQuestionIds': snapshot.recentQuestionIds,
      'sessionsCompleted': snapshot.sessionsCompleted,
      'skillHistory': {
        for (final entry in snapshot.skillHistory.entries)
          entry.key.name: entry.value.toJson(),
      },
    };

    await preferences.setString(
      _key(lessonNumber),
      jsonEncode(payload),
    );
  }
}
