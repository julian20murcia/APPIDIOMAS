import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class EnglishPronunciationLessonProgress {
  final int lessonNumber;
  final bool completed;
  final int bestAverage;
  final int attempts;
  final String? updatedAt;

  const EnglishPronunciationLessonProgress({
    required this.lessonNumber,
    required this.completed,
    required this.bestAverage,
    required this.attempts,
    this.updatedAt,
  });

  factory EnglishPronunciationLessonProgress.fromJson(Map<String, dynamic> json) {
    return EnglishPronunciationLessonProgress(
      lessonNumber: (json['lessonNumber'] as num?)?.toInt() ?? 0,
      completed: json['completed'] == true,
      bestAverage: (json['bestAverage'] as num?)?.toInt() ?? 0,
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'lessonNumber': lessonNumber,
        'completed': completed,
        'bestAverage': bestAverage,
        'attempts': attempts,
        'updatedAt': updatedAt,
      };
}

class EnglishPronunciationProgressService {
  static const _key = 'lingoverse_english_pronunciation_v1';

  Future<Map<int, EnglishPronunciationLessonProgress>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return {};
      final map = <int, EnglishPronunciationLessonProgress>{};
      for (final item in decoded) {
        if (item is! Map) continue;
        final value = EnglishPronunciationLessonProgress.fromJson(Map<String, dynamic>.from(item));
        if (value.lessonNumber > 0) map[value.lessonNumber] = value;
      }
      return map;
    } catch (_) {
      return {};
    }
  }

  Future<EnglishPronunciationLessonProgress?> loadLesson(int lessonNumber) async {
    return (await loadAll())[lessonNumber];
  }

  Future<EnglishPronunciationLessonProgress> save({
    required int lessonNumber,
    required int average,
    required int attempts,
    required bool completed,
  }) async {
    final all = await loadAll();
    final previous = all[lessonNumber];
    final value = EnglishPronunciationLessonProgress(
      lessonNumber: lessonNumber,
      completed: completed || previous?.completed == true,
      bestAverage: mathMax(average, previous?.bestAverage ?? 0),
      attempts: (previous?.attempts ?? 0) + attempts,
      updatedAt: DateTime.now().toIso8601String(),
    );
    all[lessonNumber] = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(all.values.map((e) => e.toJson()).toList()));
    return value;
  }

  int mathMax(int a, int b) => a > b ? a : b;
}
