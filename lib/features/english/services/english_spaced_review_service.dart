import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class EnglishReviewCardState {
  final String id;
  final int lessonNumber;
  final String english;
  final String spanish;
  final int streak;
  final int correct;
  final int total;
  final String dueAt;

  const EnglishReviewCardState({
    required this.id,
    required this.lessonNumber,
    required this.english,
    required this.spanish,
    required this.streak,
    required this.correct,
    required this.total,
    required this.dueAt,
  });

  DateTime get dueDate => DateTime.tryParse(dueAt) ?? DateTime.now();

  factory EnglishReviewCardState.fromJson(Map<String, dynamic> json) {
    return EnglishReviewCardState(
      id: json['id'] as String? ?? '',
      lessonNumber: (json['lessonNumber'] as num?)?.toInt() ?? 0,
      english: json['english'] as String? ?? '',
      spanish: json['spanish'] as String? ?? '',
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      correct: (json['correct'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      dueAt: json['dueAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'lessonNumber': lessonNumber,
        'english': english,
        'spanish': spanish,
        'streak': streak,
        'correct': correct,
        'total': total,
        'dueAt': dueAt,
      };
}

class EnglishSpacedReviewService {
  static const _key = 'lingoverse_english_spaced_review_v1';

  Future<Map<String, EnglishReviewCardState>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return {};
      return {
        for (final item in decoded)
          if (item is Map)
            EnglishReviewCardState.fromJson(Map<String, dynamic>.from(item)).id:
                EnglishReviewCardState.fromJson(Map<String, dynamic>.from(item)),
      }..removeWhere((key, value) => key.isEmpty);
    } catch (_) {
      return {};
    }
  }

  Future<List<EnglishReviewCardState>> syncAndGetDue({
    required List<({int lessonNumber, String english, String spanish})> vocabulary,
    int limit = 12,
  }) async {
    final states = await load();
    final now = DateTime.now();

    for (final item in vocabulary) {
      final id = '${item.lessonNumber}:${_slug(item.english)}';
      states.putIfAbsent(
        id,
        () => EnglishReviewCardState(
          id: id,
          lessonNumber: item.lessonNumber,
          english: item.english,
          spanish: item.spanish,
          streak: 0,
          correct: 0,
          total: 0,
          dueAt: now.subtract(const Duration(minutes: 1)).toIso8601String(),
        ),
      );
    }

    await _save(states);

    final due = states.values
        .where((card) => !card.dueDate.isAfter(now))
        .toList()
      ..sort((a, b) {
        final byDue = a.dueDate.compareTo(b.dueDate);
        if (byDue != 0) return byDue;
        return a.streak.compareTo(b.streak);
      });

    return due.take(limit).toList();
  }

  Future<void> record(EnglishReviewCardState card, {required bool correct}) async {
    final states = await load();
    final nextStreak = correct ? card.streak + 1 : 0;
    final intervals = <int>[1, 2, 4, 7, 14, 30];
    final interval = correct
        ? intervals[nextStreak.clamp(1, intervals.length).toInt() - 1]
        : 1;

    states[card.id] = EnglishReviewCardState(
      id: card.id,
      lessonNumber: card.lessonNumber,
      english: card.english,
      spanish: card.spanish,
      streak: nextStreak,
      correct: card.correct + (correct ? 1 : 0),
      total: card.total + 1,
      dueAt: DateTime.now().add(Duration(days: interval)).toIso8601String(),
    );
    await _save(states);
  }

  Future<int> dueCount() async {
    final now = DateTime.now();
    final states = await load();
    return states.values.where((card) => !card.dueDate.isAfter(now)).length;
  }

  Future<void> _save(Map<String, EnglishReviewCardState> states) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(states.values.map((e) => e.toJson()).toList()),
    );
  }

  String _slug(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}
