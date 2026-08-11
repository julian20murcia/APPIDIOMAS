import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/theme/brand.dart';
import '../../../data/english_level_1_curriculum.dart';
import '../../../models/english_lesson.dart';
import 'premium_game_shared.dart';

class ColorHuntGame extends StatefulWidget {
  final EnglishLesson lesson;
  const ColorHuntGame({super.key, required this.lesson});

  @override
  State<ColorHuntGame> createState() => _ColorHuntGameState();
}

class _ColorHuntGameState extends State<ColorHuntGame>
    with SingleTickerProviderStateMixin {
  final _rng = math.Random();
  late final AnimationController _motion;

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
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  Color? _color(String english) {
    switch (english.toLowerCase()) {
      case 'white':
        return Colors.white;
      case 'black':
        return const Color(0xFF111111);
      case 'red':
        return Colors.redAccent;
      case 'pink':
        return Colors.pinkAccent;
      case 'yellow':
        return Colors.yellow;
      case 'blue':
        return Colors.blue;
      case 'turquoise-blue':
        return Colors.cyanAccent;
      case 'navy blue':
        return const Color(0xFF173D73);
      case 'green':
        return Colors.green;
      case 'violet':
        return Colors.deepPurpleAccent;
      case 'orange':
        return Colors.orange;
      case 'brown':
        return Colors.brown;
      case 'grey':
        return Colors.grey;
      case 'silver':
        return const Color(0xFFB9C1CB);
      case 'gold-coloured':
        return const Color(0xFFFFD54F);
      default:
        return null;
    }
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
        _streak++;
      } else {
        _streak = 0;
      }
    });
  }

  void _next() {
    if (_round >= _vocab.length - 1) {
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
    final accent = const Color(0xFFFF7AA8);
    final english = _pair.english as String;
    final targetColor = _color(english);

    return PremiumGameScaffold(
      eyebrow: 'COLOR HUNT',
      title: 'Catch the Color',
      subtitle:
          'Colors move around the board. Read the English target and hit the right one.',
      icon: Icons.palette_rounded,
      accent: accent,
      progress: (_round + 1) / _vocab.length,
      score: _score,
      streak: _streak,
      onClose: () => Navigator.pop(context, false),
      child: PremiumGamePanel(
        accent: accent,
        child: Column(
          children: [
            Text(
              targetColor != null ? 'TAP: $english' : 'MATCH: $english',
              style: const TextStyle(
                color: Brand.white,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'English first. Use the visual clue.',
              style: TextStyle(
                color: Brand.white.withOpacity(.48),
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            if (targetColor != null)
              _movingBoard(english)
            else
              _styleBoard(english),
            if (_answered) ...[
              GameFeedback(
                correct: _correct,
                correctText: english,
              ),
              GameNextButton(
                last: _round >= _vocab.length - 1,
                onTap: _next,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _movingBoard(String target) {
    final candidates = _vocab
        .map((e) => e.english as String)
        .where((e) => _color(e) != null)
        .toList()
      ..shuffle(_rng);

    final visible = <String>[
      target,
      ...candidates.where((e) => e != target).take(5),
    ]..shuffle(_rng);

    return SizedBox(
      height: 285,
      child: AnimatedBuilder(
        animation: _motion,
        builder: (_, __) {
          return Stack(
            children: List.generate(visible.length, (i) {
              final value = visible[i];
              final wave = (_motion.value * math.pi * 2) + i;
              final left =
                  18 + (i % 3) * 96 + math.sin(wave) * 8;
              final top =
                  18 + (i ~/ 3) * 120 + math.cos(wave * .8) * 9;
              final c = _color(value)!;
              final correct = _answered && value == target;
              final wrong =
                  _answered && _selected == value && value != target;

              return Positioned(
                left: left.toDouble(),
                top: top.toDouble(),
                child: InkWell(
                  onTap: _answered ? null : () => _answer(value),
                  customBorder: const CircleBorder(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: correct
                            ? const Color(0xFF66E6A3)
                            : wrong
                                ? Colors.redAccent
                                : Colors.white24,
                        width: correct || wrong ? 4 : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: c.withOpacity(.28),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _styleBoard(String target) {
    const styles = <String, (Color, double, double)>{
      'Light': (Color(0xFF98D8FF), .55, 1),
      'Dark': (Color(0xFF17344E), 1, 1),
      'Bright': (Color(0xFFFFF36C), 1, 3),
      'Loud': (Color(0xFFFF477E), 1, 4),
      'Fluorescent': (Color(0xFF66FF66), 1, 3),
      'Intense': (Color(0xFF6E24FF), 1, 2),
      'Matt': (Color(0xFF73808D), .85, 0),
    };

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: styles.entries.map((entry) {
        final name = entry.key;
        final data = entry.value;
        return InkWell(
          onTap: _answered ? null : () => _answer(name),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 106,
            height: 88,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: data.$1.withOpacity(data.$2),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white70,
                width: data.$3,
              ),
              boxShadow: name == 'Bright' || name == 'Fluorescent'
                  ? [
                      BoxShadow(
                        color: data.$1.withOpacity(.40),
                        blurRadius: 18,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              name,
              style: TextStyle(
                color: name == 'Light' ||
                        name == 'Bright' ||
                        name == 'Fluorescent'
                    ? Brand.bgDeep
                    : Brand.white,
                fontWeight: FontWeight.w900,
                fontSize: 11.5,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
