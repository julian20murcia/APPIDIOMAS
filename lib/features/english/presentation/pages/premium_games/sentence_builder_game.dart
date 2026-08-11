import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../../../core/theme/brand.dart';
import '../../../data/english_level_1_curriculum.dart';
import '../../../models/english_lesson.dart';
import 'premium_game_shared.dart';

class SentenceBuilderGame extends StatefulWidget {
  final EnglishLesson lesson;
  const SentenceBuilderGame({super.key, required this.lesson});

  @override
  State<SentenceBuilderGame> createState() => _SentenceBuilderGameState();
}

class _SentenceBuilderGameState extends State<SentenceBuilderGame> {
  final _rng = math.Random();
  final _tts = FlutterTts();

  int _round = 0;
  int _score = 0;
  int _streak = 0;
  bool _answered = false;
  bool _correct = false;

  List<String> _available = [];
  List<String> _built = [];

  List<dynamic> get _vocab =>
      englishLevel1Vocabulary[widget.lesson.number] ?? const [];
  dynamic get _pair => _vocab[_round % _vocab.length];

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(.42);
    _prepare();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  String get _target => (_pair.english as String)
      .replaceAll(RegExp(r"[^A-Za-z0-9' ]"), '')
      .trim();

  void _prepare() {
    final words =
        _target.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    _available = List<String>.from(words)..shuffle(_rng);
    _built = [];
    _answered = false;
    _correct = false;
  }

  void _add(String word) {
    if (_answered) return;
    setState(() {
      final i = _available.indexOf(word);
      if (i >= 0) {
        _available.removeAt(i);
        _built.add(word);
      }
    });

    if (_available.isEmpty) {
      final ok = _built.join(' ') == _target;
      setState(() {
        _answered = true;
        _correct = ok;
        if (ok) {
          _score += 120 + _streak * 15;
          _streak++;
        } else {
          _streak = 0;
        }
      });
    }
  }

  void _remove(String word) {
    if (_answered) return;
    setState(() {
      final i = _built.lastIndexOf(word);
      if (i >= 0) {
        _built.removeAt(i);
        _available.add(word);
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
      _prepare();
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFFFFC968);

    return PremiumGameScaffold(
      eyebrow: 'SENTENCE BUILDER',
      title: 'Build with HAVE',
      subtitle:
          'Construct English sentences, then hear how the final sentence sounds.',
      icon: Icons.construction_rounded,
      accent: accent,
      progress: (_round + 1) / _vocab.length,
      score: _score,
      streak: _streak,
      onClose: () => Navigator.pop(context, false),
      child: PremiumGamePanel(
        accent: accent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'BUILD THE SENTENCE',
              style: TextStyle(
                color: Color(0xFFFFC968),
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                letterSpacing: .8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _pair.spanish as String,
              style: TextStyle(
                color: Brand.white.withOpacity(.55),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            DragTarget<String>(
              onAcceptWithDetails: (details) => _add(details.data),
              builder: (_, candidate, __) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 100),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: candidate.isNotEmpty
                        ? accent.withOpacity(.10)
                        : Brand.bgDeep.withOpacity(.44),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: candidate.isNotEmpty
                          ? accent.withOpacity(.55)
                          : Brand.white.withOpacity(.08),
                    ),
                  ),
                  child: _built.isEmpty
                      ? Center(
                          child: Text(
                            'Drag words here',
                            style: TextStyle(
                              color: Brand.white.withOpacity(.30),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _built
                              .map(
                                (word) => ActionChip(
                                  backgroundColor: accent.withOpacity(.15),
                                  side: BorderSide(
                                    color: accent.withOpacity(.30),
                                  ),
                                  label: Text(
                                    word,
                                    style: const TextStyle(
                                      color: Brand.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  onPressed:
                                      _answered ? null : () => _remove(word),
                                ),
                              )
                              .toList(),
                        ),
                );
              },
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _available.map((word) {
                return Draggable<String>(
                  data: word,
                  feedback: Material(
                    color: Colors.transparent,
                    child: _wordTile(word, accent, elevated: true),
                  ),
                  childWhenDragging: Opacity(
                    opacity: .25,
                    child: _wordTile(word, accent),
                  ),
                  child: InkWell(
                    onTap: () => _add(word),
                    child: _wordTile(word, accent),
                  ),
                );
              }).toList(),
            ),
            if (_answered) ...[
              GameFeedback(
                correct: _correct,
                correctText: _target,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await _tts.stop();
                    await _tts.speak(_target);
                  },
                  icon: const Icon(Icons.volume_up_rounded),
                  label: const Text('Hear the sentence'),
                ),
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

  Widget _wordTile(
    String word,
    Color accent, {
    bool elevated = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: elevated ? accent : Brand.white.withOpacity(.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: elevated ? accent : Brand.white.withOpacity(.09),
        ),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(.25),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: Text(
        word,
        style: TextStyle(
          color: elevated ? Brand.bgDeep : Brand.white,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
