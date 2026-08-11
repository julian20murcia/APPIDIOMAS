import 'package:flutter/material.dart';

import '../../models/english_lesson.dart';
import 'premium_games/color_hunt_game.dart';
import 'premium_games/dialogue_play_game.dart';
import 'premium_games/family_memory_game.dart';
import 'premium_games/number_rush_game.dart';
import 'premium_games/preposition_scene_game.dart';
import 'premium_games/sentence_builder_game.dart';

class PremiumLessonGamePage extends StatelessWidget {
  final EnglishLesson lesson;

  const PremiumLessonGamePage({
    super.key,
    required this.lesson,
  });

  static bool supports(int lessonNumber) {
    return const {1, 7, 9, 10, 12, 32}.contains(lessonNumber);
  }

  @override
  Widget build(BuildContext context) {
    switch (lesson.number) {
      case 1:
        return DialoguePlayGame(lesson: lesson);
      case 7:
        return NumberRushGame(lesson: lesson);
      case 9:
        return ColorHuntGame(lesson: lesson);
      case 10:
        return FamilyMemoryGame(lesson: lesson);
      case 12:
        return SentenceBuilderGame(lesson: lesson);
      case 32:
        return PrepositionSceneGame(lesson: lesson);
      default:
        return const Scaffold(
          body: Center(child: Text('Premium game unavailable')),
        );
    }
  }
}
