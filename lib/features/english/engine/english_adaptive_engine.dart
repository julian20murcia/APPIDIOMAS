import 'dart:math' as math;

import '../models/english_activity.dart';
import '../data/english_level_1_profiles.dart';
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
    bool practice = false,
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

    final selected = _selectPedagogicalSession(
      source: source,
      history: history,
      targetDifficulty: targetDifficulty,
      count: math.min(activityCount, source.length),
      random: random,
      lessonNumber: lesson.number,
      practice: practice,
    );

    final randomized = selected
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


  List<EnglishActivity> _selectPedagogicalSession({
    required List<EnglishActivity> source,
    required EnglishQuestionHistorySnapshot history,
    required EnglishDifficulty targetDifficulty,
    required int count,
    required math.Random random,
    required int lessonNumber,
    required bool practice,
  }) {
    // La primera sesión enseña antes de exigir producción. En sesiones
    // posteriores aumentamos gradualmente completar/escribir y priorizamos
    // habilidades débiles, siempre dentro del banco de la misma lección.
    final firstExposure = history.sessionsCompleted == 0;
    final strongLearner = history.sessionsCompleted > 0 && history.globalAccuracy >= 0.82;

    final profile = englishLevel1ActivityProfiles[lessonNumber];
    final basePattern = practice
        ? (profile?.practicePattern ?? const <EnglishActivityType>[])
        : (profile?.evaluationPattern ?? const <EnglishActivityType>[]);

    final preferredTypes = basePattern.isNotEmpty
        ? List<EnglishActivityType>.generate(
            count,
            (index) => basePattern[index % basePattern.length],
          )
        : firstExposure
            ? <EnglishActivityType>[
                EnglishActivityType.multipleChoice,
                EnglishActivityType.listenChoice,
                EnglishActivityType.speakAnswer,
                EnglishActivityType.trueFalse,
                EnglishActivityType.orderWords,
                EnglishActivityType.fillBlank,
              ]
            : strongLearner
                ? <EnglishActivityType>[
                    EnglishActivityType.listenChoice,
                    EnglishActivityType.speakAnswer,
                    EnglishActivityType.fillBlank,
                    EnglishActivityType.orderWords,
                    EnglishActivityType.writeAnswer,
                    EnglishActivityType.multipleChoice,
                  ]
                : <EnglishActivityType>[
                    EnglishActivityType.multipleChoice,
                    EnglishActivityType.listenChoice,
                    EnglishActivityType.fillBlank,
                    EnglishActivityType.orderWords,
                    EnglishActivityType.writeAnswer,
                    EnglishActivityType.speakAnswer,
                  ];

    final remaining = List<EnglishActivity>.from(source);
    final result = <EnglishActivity>[];
    final usedConcepts = <String>{};

    for (final type in preferredTypes) {
      if (result.length >= count || remaining.isEmpty) break;

      var candidates = remaining.where((item) => item.type == type).toList();
      if (candidates.isEmpty) continue;
      final freshConcepts = candidates.where((item) => item.conceptKey.isEmpty || !usedConcepts.contains(item.conceptKey)).toList();
      if (freshConcepts.isNotEmpty) candidates = freshConcepts;

      final picked = _pickWeightedActivity(
        candidates: candidates,
        history: history,
        targetDifficulty: targetDifficulty,
        random: random,
        firstExposure: firstExposure,
      );
      result.add(picked);
      if (picked.conceptKey.isNotEmpty) usedConcepts.add(picked.conceptKey);
      remaining.removeWhere((item) => item.id == picked.id);
    }

    if (result.length < count && remaining.isNotEmpty) {
      final filler = _weightedSelection(
        source: remaining,
        history: history,
        targetDifficulty: firstExposure ? EnglishDifficulty.easy : targetDifficulty,
        count: count - result.length,
        random: random,
        lessonNumber: lessonNumber,
        practice: practice,
      );
      result.addAll(filler);
    }

    return result.take(count).toList();
  }

  EnglishActivity _pickWeightedActivity({
    required List<EnglishActivity> candidates,
    required EnglishQuestionHistorySnapshot history,
    required EnglishDifficulty targetDifficulty,
    required math.Random random,
    required bool firstExposure,
  }) {
    final weights = candidates.map((activity) {
      var weight = history.weaknessWeight(activity.skill);

      if (firstExposure && activity.difficulty == EnglishDifficulty.hard) {
        weight *= 0.18;
      } else if (activity.difficulty == targetDifficulty) {
        weight *= 1.65;
      } else if (_difficultyDistance(activity.difficulty, targetDifficulty) == 1) {
        weight *= 1.1;
      } else {
        weight *= 0.65;
      }

      if (!history.recentQuestionIds.contains(activity.id)) {
        weight *= 1.35;
      }

      return weight.clamp(0.05, 10.0).toDouble();
    }).toList();

    return candidates[_weightedIndex(weights, random)];
  }

  List<EnglishActivity> _weightedSelection({
    required List<EnglishActivity> source,
    required EnglishQuestionHistorySnapshot history,
    required EnglishDifficulty targetDifficulty,
    required int count,
    required math.Random random,
    required int lessonNumber,
    required bool practice,
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
            activity.type == EnglishActivityType.listenChoice ||
            activity.type == EnglishActivityType.speakAnswer) {
          weight *= 1.18;
        }

        return weight.clamp(0.1, 10.0).toDouble();
      }).toList();

      final pickedIndex = _weightedIndex(weights, random);
      selected.add(remaining.removeAt(pickedIndex));
    }

    return selected;
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
