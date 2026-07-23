import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import '../lib/features/english/data/english_level_1_data.dart';
import '../lib/features/english/engine/english_question_factory.dart';

Future<void> main() async {
  final output = <Map<String, dynamic>>[];

  for (final lesson in englishLevel1Data) {
    final factory = EnglishQuestionFactory(
      random: math.Random(lesson.number * 9173),
    );
    final activities = factory.buildPool(lesson);

    output.add({
      'lessonNumber': lesson.number,
      'lessonTitle': lesson.title,
      'questions': activities.map((activity) {
        return {
          'id': activity.id,
          'type': activity.type.name,
          'skill': activity.skill.name,
          'difficulty': activity.difficulty.name,
          'prompt': activity.prompt,
          'instruction': activity.instruction,
          'answer': activity.answer,
          'acceptedAnswers': activity.acceptedAnswers,
          'options': activity.options,
          'words': activity.words,
          'explanation': activity.explanation,
          'hint': activity.hint,
          'speechText': activity.speechText,
          'seconds': activity.seconds,
          'basePoints': activity.basePoints,
        };
      }).toList(),
    });
  }

  final directory = Directory('build');
  await directory.create(recursive: true);

  final file = File('build/question_banks.json');
  await file.writeAsString(
    
    const JsonEncoder.withIndent('  ').convert(output),
  );

  stdout.writeln(
    'Banco exportado: ${file.path} · ${englishLevel1Data.length} lecciones.',
  );
}
