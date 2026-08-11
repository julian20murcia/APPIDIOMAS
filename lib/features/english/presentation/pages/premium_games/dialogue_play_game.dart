import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../../../core/theme/brand.dart';
import '../../../data/english_level_1_curriculum.dart';
import '../../../models/english_lesson.dart';
import 'premium_game_shared.dart';

class DialoguePlayGame extends StatefulWidget {
  final EnglishLesson lesson;
  const DialoguePlayGame({super.key, required this.lesson});

  @override
  State<DialoguePlayGame> createState() => _DialoguePlayGameState();
}

class _DialoguePlayGameState extends State<DialoguePlayGame> {
  final _rng = math.Random();
  final _tts = FlutterTts();

  int _round = 0;
  int _score = 0;
  int _streak = 0;
  String? _selected;
  bool _answered = false;
  bool _correct = false;

  List<dynamic> get _vocab =>
      englishLevel1Vocabulary[widget.lesson.number] ?? const [];
  dynamic get _pair => _vocab[_round % _vocab.length];

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(.42);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  List<String> _options() {
    final target = _pair.english as String;
    final pool = _vocab
        .where((e) => e.english != target)
        .map((e) => e.english as String)
        .toList()
      ..shuffle(_rng);
    return <String>[target, ...pool.take(3)]..shuffle(_rng);
  }

  void _answer(String value) {
    if (_answered) return;
    final ok = value == _pair.english;
    setState(() {
      _selected = value;
      _answered = true;
      _correct = ok;
      if (ok) {
        _score += 100 + _streak * 15;
        _streak += 1;
      } else {
        _streak = 0;
      }
    });
  }

  void _next() {
    if (_round >= math.min(9, _vocab.length - 1)) {
      Navigator.pop(context, true);
      return;
    }
    setState(() {
      _round++;
      _selected = null;
      _answered = false;
      _correct = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = math.min(10, _vocab.length);
    final accent = const Color(0xFFFFCE67);

    return PremiumGameScaffold(
      eyebrow: 'DIALOGUE PLAY',
      title: 'Welcome Story',
      subtitle:
          'Move through a real conversation. Listen, react and keep the dialogue alive.',
      icon: Icons.forum_rounded,
      accent: accent,
      progress: (_round + 1) / total,
      score: _score,
      streak: _streak,
      onClose: () => Navigator.pop(context, false),
      child: PremiumGamePanel(
        accent: accent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SCENE ${_round + 1}',
              style: const TextStyle(
                color: Color(0xFFFFCE67),
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                letterSpacing: .8,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF142D45),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 27,
                    backgroundColor: Color(0x3329B6F6),
                    child: Icon(
                      Icons.person_rounded,
                      color: Color(0xFFFFCE67),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _scenePrompt(_round),
                          style: TextStyle(
                            color: Brand.white.withOpacity(.55),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _pair.english as String,
                          style: const TextStyle(
                            color: Brand.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await _tts.stop();
                      await _tts.speak(_pair.english as String);
                    },
                    icon: const Icon(
                      Icons.volume_up_rounded,
                      color: Color(0xFFFFCE67),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Choose the response that keeps the conversation going.',
              style: TextStyle(
                color: Brand.white.withOpacity(.55),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 9),
            ..._options().map(
              (option) => GameOption(
                text: option,
                accent: accent,
                selected: _selected == option,
                correct: _answered && option == _pair.english,
                wrong: _answered &&
                    _selected == option &&
                    option != _pair.english,
                onTap: _answered ? null : () => _answer(option),
              ),
            ),
            if (_answered) ...[
              GameFeedback(
                correct: _correct,
                correctText: _pair.english as String,
              ),
              GameNextButton(
                last: _round >= total - 1,
                onTap: _next,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _scenePrompt(int round) {
    switch (round % 4) {
      case 0:
        return 'You just met someone.';
      case 1:
        return 'The other person asks about you.';
      case 2:
        return 'Keep the introduction natural.';
      default:
        return 'Finish the exchange politely.';
    }
  }
}
