import 'dart:math' as math;

import '../models/english_activity.dart';
import '../models/english_learning_session.dart';
import '../models/english_lesson.dart';
import '../services/english_question_history_service.dart';
import 'english_question_factory.dart';

class EnglishAdaptiveEngine {
  final EnglishQuestionHistoryService historyService;

  EnglishAdaptiveEngine({
    EnglishQuestionHistoryService? historyService,
  }) : historyService =
            historyService ?? EnglishQuestionHistoryService();

  Future<EnglishLearningSession> createSession({
    required EnglishLesson lesson,
    required int attempt,
    int activityCount = 12,
  }) async {
    final history = await historyService.load(lesson.number);
    final random = math.Random.secure();
    final factory = EnglishQuestionFactory(random: random);
    final pool = factory.buildPool(lesson);

    if (pool.isEmpty) {
      throw StateError(
        'No fue posible construir actividades para la lección ${lesson.number}.',
      );
    }

    final targetDifficulty = _targetDifficulty(
      history: history,
      attempt: attempt,
    );

    final recentIds = history.recentQuestionIds.toSet();
    final unseen = pool
        .where((activity) => !recentIds.contains(activity.id))
        .toList();

    final source = unseen.length >= activityCount
        ? unseen
        : <EnglishActivity>[
            ...unseen,
            ...pool.where((item) => recentIds.contains(item.id)),
          ];

    final selected = _weightedSelection(
      source: source,
      history: history,
      targetDifficulty: targetDifficulty,
      count: math.min(activityCount, source.length),
      random: random,
    );

    final diversified = _ensureTypeVariety(
      selected: selected,
      fullPool: source,
      count: math.min(activityCount, source.length),
      random: random,
    );

    final randomized = diversified
        .map((activity) => _randomizeActivity(activity, random))
        .toList();

    return EnglishLearningSession(
      id: _sessionId(lesson.number, random),
      lessonNumber: lesson.number,
      attempt: attempt,
      targetDifficulty: targetDifficulty,
      activities: randomized,
      createdAt: DateTime.now(),
    );
  }

  EnglishDifficulty _targetDifficulty({
    required EnglishQuestionHistorySnapshot history,
    required int attempt,
  }) {
    if (history.sessionsCompleted == 0) {
      return EnglishDifficulty.easy;
    }

    final accuracy = history.globalAccuracy;

    if (accuracy >= 0.86 && attempt <= 2) {
      return EnglishDifficulty.hard;
    }

    if (accuracy >= 0.64) {
      return EnglishDifficulty.medium;
    }

    return EnglishDifficulty.easy;
  }

  List<EnglishActivity> _weightedSelection({
    required List<EnglishActivity> source,
    required EnglishQuestionHistorySnapshot history,
    required EnglishDifficulty targetDifficulty,
    required int count,
    required math.Random random,
  }) {
    final remaining = List<EnglishActivity>.from(source);
    final selected = <EnglishActivity>[];

    while (remaining.isNotEmpty && selected.length < count) {
      final weights = remaining.map((activity) {
        var weight = history.weaknessWeight(activity.skill);

        if (activity.difficulty == targetDifficulty) {
          weight *= 1.75;
        } else if (_difficultyDistance(
              activity.difficulty,
              targetDifficulty,
            ) ==
            1) {
          weight *= 1.15;
        } else {
          weight *= 0.72;
        }

        if (!history.recentQuestionIds.contains(activity.id)) {
          weight *= 1.55;
        }

        if (activity.type == EnglishActivityType.writeAnswer ||
            activity.type == EnglishActivityType.orderWords ||
            activity.type == EnglishActivityType.listenChoice) {
          weight *= 1.18;
        }

        return weight.clamp(0.1, 10.0).toDouble();
      }).toList();

      final pickedIndex = _weightedIndex(weights, random);
      selected.add(remaining.removeAt(pickedIndex));
    }

    return selected;
  }

  List<EnglishActivity> _ensureTypeVariety({
    required List<EnglishActivity> selected,
    required List<EnglishActivity> fullPool,
    required int count,
    required math.Random random,
  }) {
    final result = List<EnglishActivity>.from(selected);

    const desiredTypes = [
      EnglishActivityType.multipleChoice,
      EnglishActivityType.listenChoice,
      EnglishActivityType.orderWords,
      EnglishActivityType.fillBlank,
      EnglishActivityType.writeAnswer,
      EnglishActivityType.trueFalse,
    ];

    for (final type in desiredTypes) {
      if (result.any((item) => item.type == type)) continue;

      final candidates = fullPool
          .where(
            (item) =>
                item.type == type &&
                !result.any((selectedItem) => selectedItem.id == item.id),
          )
          .toList();

      if (candidates.isEmpty) continue;

      final replacement = candidates[random.nextInt(candidates.length)];

      if (result.length < count) {
        result.add(replacement);
      } else if (result.isNotEmpty) {
        final duplicateTypeIndex = result.indexWhere((item) {
          final occurrences = result
              .where((candidate) => candidate.type == item.type)
              .length;
          return occurrences > 2;
        });

        if (duplicateTypeIndex >= 0) {
          result[duplicateTypeIndex] = replacement;
        }
      }
    }

    result.shuffle(random);
    return result.take(count).toList();
  }

  EnglishActivity _randomizeActivity(
    EnglishActivity activity,
    math.Random random,
  ) {
    final options = List<String>.from(activity.options)..shuffle(random);
    final words = List<String>.from(activity.words)..shuffle(random);

    return activity.copyWith(
      options: options,
      words: words,
    );
  }

  int _weightedIndex(List<double> weights, math.Random random) {
    final total = weights.fold<double>(0, (sum, item) => sum + item);
    var target = random.nextDouble() * total;

    for (var index = 0; index < weights.length; index++) {
      target -= weights[index];
      if (target <= 0) return index;
    }

    return weights.length - 1;
  }

  int _difficultyDistance(
    EnglishDifficulty a,
    EnglishDifficulty b,
  ) {
    return (a.index - b.index).abs();
  }

  String _sessionId(int lessonNumber, math.Random random) {
    final now = DateTime.now().microsecondsSinceEpoch;
    final nonce = random.nextInt(1 << 30);
    return 'eng-$lessonNumber-$now-$nonce';
  }
}
