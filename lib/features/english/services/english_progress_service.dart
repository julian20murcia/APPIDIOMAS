import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class EnglishLessonResult {
  final int lessonNumber;
  final int score;
  final int attempts;
  final int xp;
  final bool passed;
  final String? completedAt;

  const EnglishLessonResult({
    required this.lessonNumber,
    required this.score,
    required this.attempts,
    required this.xp,
    required this.passed,
    this.completedAt,
  });

  factory EnglishLessonResult.fromJson(Map<String, dynamic> json) {
    return EnglishLessonResult(
      lessonNumber: (json['lessonNumber'] as num?)?.toInt() ?? 0,
      score: (json['score'] as num?)?.toInt() ?? 0,
      attempts: (json['attempts'] as num?)?.toInt() ?? 1,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      passed: json['passed'] == true,
      completedAt: json['completedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonNumber': lessonNumber,
      'score': score,
      'attempts': attempts,
      'xp': xp,
      'passed': passed,
      'completedAt': completedAt,
    };
  }
}

class EnglishProgressSnapshot {
  final Map<int, EnglishLessonResult> results;
  final int completedLessons;
  final int totalXp;

  const EnglishProgressSnapshot({
    required this.results,
    required this.completedLessons,
    required this.totalXp,
  });

  factory EnglishProgressSnapshot.empty() {
    return const EnglishProgressSnapshot(
      results: {},
      completedLessons: 0,
      totalXp: 0,
    );
  }

  int get nextLessonNumber => completedLessons + 1;

  bool isCompleted(int lessonNumber) {
    return results[lessonNumber]?.passed == true;
  }

  bool isUnlocked(int lessonNumber) {
    return lessonNumber <= nextLessonNumber;
  }

  int? scoreFor(int lessonNumber) {
    return results[lessonNumber]?.score;
  }
}

class EnglishProgressService {
  static const String _storageKey = 'lingoverse_english_level_1_progress';

  Future<EnglishProgressSnapshot> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);

    if (raw == null || raw.trim().isEmpty) {
      return EnglishProgressSnapshot.empty();
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! Map<String, dynamic>) {
        return EnglishProgressSnapshot.empty();
      }

      final rawResults = decoded['results'];
      final results = <int, EnglishLessonResult>{};

      if (rawResults is List) {
        for (final item in rawResults) {
          if (item is! Map) continue;

          final result = EnglishLessonResult.fromJson(
            Map<String, dynamic>.from(item),
          );

          if (result.lessonNumber > 0) {
            results[result.lessonNumber] = result;
          }
        }
      }

      return _buildSnapshot(results);
    } catch (_) {
      return EnglishProgressSnapshot.empty();
    }
  }

  Future<EnglishProgressSnapshot> saveLessonResult({
    required int lessonNumber,
    required int score,
    required bool passed,
    required int attempts,
    required int xp,
  }) async {
    final current = await load();
    final results = Map<int, EnglishLessonResult>.from(current.results);
    final previous = results[lessonNumber];

    final bestScore = previous == null
        ? score
        : score > previous.score
            ? score
            : previous.score;

    final bestXp = previous == null
        ? xp
        : xp > previous.xp
            ? xp
            : previous.xp;

    final everPassed = passed || previous?.passed == true;

    results[lessonNumber] = EnglishLessonResult(
      lessonNumber: lessonNumber,
      score: bestScore,
      attempts: attempts,
      xp: bestXp,
      passed: everPassed,
      completedAt: everPassed
          ? previous?.completedAt ?? DateTime.now().toIso8601String()
          : null,
    );

    final snapshot = _buildSnapshot(results);
    await _save(snapshot);
    return snapshot;
  }

  Future<void> reset() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_storageKey);
  }

  EnglishProgressSnapshot _buildSnapshot(
    Map<int, EnglishLessonResult> results,
  ) {
    var completedLessons = 0;

    while (results[completedLessons + 1]?.passed == true) {
      completedLessons++;
    }

    final totalXp = results.values.fold<int>(
      0,
      (total, result) => total + result.xp,
    );

    return EnglishProgressSnapshot(
      results: Map<int, EnglishLessonResult>.unmodifiable(results),
      completedLessons: completedLessons,
      totalXp: totalXp,
    );
  }

  Future<void> _save(EnglishProgressSnapshot snapshot) async {
    final preferences = await SharedPreferences.getInstance();

    final payload = {
      'completedLessons': snapshot.completedLessons,
      'totalXp': snapshot.totalXp,
      'results': snapshot.results.values
          .map((result) => result.toJson())
          .toList(),
    };

    await preferences.setString(
      _storageKey,
      jsonEncode(payload),
    );
  }
}
