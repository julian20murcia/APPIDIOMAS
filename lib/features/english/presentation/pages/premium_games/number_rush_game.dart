import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../../../core/theme/brand.dart';
import '../../../data/english_level_1_curriculum.dart';
import '../../../models/english_lesson.dart';
import 'premium_game_shared.dart';

class NumberRushGame extends StatefulWidget {
  final EnglishLesson lesson;
  const NumberRushGame({super.key, required this.lesson});

  @override
  State<NumberRushGame> createState() => _NumberRushGameState();
}

class _NumberRushGameState extends State<NumberRushGame> {
  final _tts = FlutterTts();
  final _rng = math.Random();

  int _round = 0;
  int _score = 0;
  int _streak = 0;
  int _seconds = 8;
  Timer? _timer;
  bool _answered = false;
  bool _correct = false;
  int? _selected;

  List<dynamic> get _vocab =>
      englishLevel1Vocabulary[widget.lesson.number] ?? const [];
  dynamic get _pair => _vocab[_round % _vocab.length];

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(.42);
    _restartTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tts.stop();
    super.dispose();
  }

  int? _value(String english) {
    const values = <String, int>{
      'Zero': 0,
      'One': 1,
      'Two': 2,
      'Three': 3,
      'Four': 4,
      'Five': 5,
      'Six': 6,
      'Seven': 7,
      'Eight': 8,
      'Nine': 9,
      'Ten': 10,
      'First': 1,
      'Second': 2,
      'Third': 3,
      'Fourth': 4,
      'Fifth': 5,
      'Sixth': 6,
      'Seventh': 7,
      'Eighth': 8,
      'Ninth': 9,
      'Tenth': 10,
    };
    return values[english];
  }

  bool _ordinal(String english) {
    return english.endsWith('th') ||
        const {'First', 'Second', 'Third'}.contains(english);
  }

  void _restartTimer() {
    _timer?.cancel();
    _seconds = 8;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _answered) {
        timer.cancel();
        return;
      }
      if (_seconds <= 1) {
        timer.cancel();
        _answer(-999);
        return;
      }
      setState(() => _seconds--);
    });
  }

  void _answer(int value) {
    if (_answered) return;
    final expected = _value(_pair.english as String);
    final ok = value == expected;
    setState(() {
      _selected = value;
      _answered = true;
      _correct = ok;
      if (ok) {
        _score += 100 + _seconds * 7 + _streak * 15;
        _streak++;
      } else {
        _streak = 0;
      }
    });
    _timer?.cancel();
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
    _restartTimer();
  }

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF67D7FF);
    final english = _pair.english as String;
    final expected = _value(english) ?? 0;
    final phase = _round % 3;

    return PremiumGameScaffold(
      eyebrow: 'NUMBER RUSH',
      title: 'Beat the Clock',
      subtitle:
          'Listen, count and complete sequences before the timer reaches zero.',
      icon: Icons.bolt_rounded,
      accent: accent,
      progress: (_round + 1) / _vocab.length,
      score: _score,
      streak: _streak,
      onClose: () => Navigator.pop(context, false),
      child: PremiumGamePanel(
        accent: accent,
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  phase == 0
                      ? 'LISTEN & TAP'
                      : phase == 1
                          ? 'COUNT IT'
                          : 'SEQUENCE',
                  style: const TextStyle(
                    color: Color(0xFF67D7FF),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .8,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                  decoration: BoxDecoration(
                    color: _seconds <= 3
                        ? Colors.redAccent.withOpacity(.12)
                        : accent.withOpacity(.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${_seconds}s',
                    style: TextStyle(
                      color: _seconds <= 3 ? Colors.redAccent : accent,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (phase == 0) _listenRound(english, expected, accent),
            if (phase == 1) _countRound(english, expected, accent),
            if (phase == 2) _sequenceRound(english, expected, accent),
            if (_answered) ...[
              GameFeedback(
                correct: _correct,
                correctText: '$english = $expected',
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

  Widget _listenRound(String english, int expected, Color accent) {
    return Column(
      children: [
        InkWell(
          onTap: () async {
            await _tts.stop();
            await _tts.speak(english);
          },
          customBorder: const CircleBorder(),
          child: Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(.28),
                  blurRadius: 22,
                ),
              ],
            ),
            child: const Icon(
              Icons.volume_up_rounded,
              color: Brand.bgDeep,
              size: 34,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Listen and tap the number',
          style: TextStyle(
            color: Brand.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        _numberGrid(expected, accent),
      ],
    );
  }

  Widget _countRound(String english, int expected, Color accent) {
    final count = expected.clamp(1, 10);
    return Column(
      children: [
        Text(
          _ordinal(english)
              ? 'Find the position: $english'
              : 'How many?',
          style: const TextStyle(
            color: Brand.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 15),
        if (_ordinal(english))
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: List.generate(
              10,
              (i) => Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: i + 1 == expected
                      ? accent.withOpacity(.16)
                      : Brand.white.withOpacity(.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: i + 1 == expected
                        ? accent
                        : Brand.white.withOpacity(.07),
                  ),
                ),
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(
                    color: Brand.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: List.generate(
              count,
              (_) => Icon(
                Icons.circle,
                color: accent,
                size: 26,
              ),
            ),
          ),
        const SizedBox(height: 15),
        _numberGrid(expected, accent),
      ],
    );
  }

  Widget _sequenceRound(String english, int expected, Color accent) {
    final before = math.max(0, expected - 1);
    final after = math.min(10, expected + 1);
    return Column(
      children: [
        const Text(
          'Complete the sequence',
          style: TextStyle(
            color: Brand.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _seq('$before', false, accent),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.arrow_forward_rounded, color: Colors.white38),
            ),
            _seq('?', true, accent),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.arrow_forward_rounded, color: Colors.white38),
            ),
            _seq('$after', false, accent),
          ],
        ),
        const SizedBox(height: 15),
        _numberGrid(expected, accent),
      ],
    );
  }

  Widget _numberGrid(int expected, Color accent) {
    final candidates = <int>{expected};
    while (candidates.length < 6) {
      candidates.add(_rng.nextInt(11));
    }
    final list = candidates.toList()..shuffle(_rng);

    return Wrap(
      spacing: 9,
      runSpacing: 9,
      alignment: WrapAlignment.center,
      children: list.map((value) {
        final isCorrect = _answered && value == expected;
        final isWrong = _answered && _selected == value && value != expected;
        return InkWell(
          onTap: _answered ? null : () => _answer(value),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 72,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isCorrect
                  ? const Color(0xFF66E6A3).withOpacity(.12)
                  : isWrong
                      ? Colors.redAccent.withOpacity(.10)
                      : Brand.white.withOpacity(.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCorrect
                    ? const Color(0xFF66E6A3)
                    : isWrong
                        ? Colors.redAccent
                        : Brand.white.withOpacity(.07),
              ),
            ),
            child: Text(
              '$value',
              style: const TextStyle(
                color: Brand.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _seq(String text, bool active, Color accent) {
    return Container(
      width: 66,
      height: 66,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? accent.withOpacity(.13) : Brand.white.withOpacity(.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: active ? accent : Brand.white.withOpacity(.07),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Brand.white,
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
