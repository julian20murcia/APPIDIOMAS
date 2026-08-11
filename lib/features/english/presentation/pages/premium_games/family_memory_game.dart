import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/theme/brand.dart';
import '../../../data/english_level_1_curriculum.dart';
import '../../../models/english_lesson.dart';
import 'premium_game_shared.dart';

class FamilyMemoryGame extends StatefulWidget {
  final EnglishLesson lesson;
  const FamilyMemoryGame({super.key, required this.lesson});

  @override
  State<FamilyMemoryGame> createState() => _FamilyMemoryGameState();
}

class _FamilyMemoryGameState extends State<FamilyMemoryGame> {
  final _rng = math.Random();

  int _set = 0;
  int _score = 0;
  int _streak = 0;
  bool _busy = false;
  final Set<int> _open = {};
  final Set<int> _matched = {};
  List<_CardData> _cards = [];

  List<dynamic> get _vocab =>
      englishLevel1Vocabulary[widget.lesson.number] ?? const [];

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  void _prepare() {
    final start = _set * 4;
    final end = math.min(start + 4, _vocab.length);
    final next = <_CardData>[];

    for (var i = start; i < end; i++) {
      final pair = _vocab[i];
      next.add(
        _CardData(
          keyValue: 'family-$i',
          text: pair.english as String,
          tag: 'EN',
        ),
      );
      next.add(
        _CardData(
          keyValue: 'family-$i',
          text: pair.spanish as String,
          tag: 'ES',
        ),
      );
    }

    next.shuffle(_rng);
    _cards = next;
    _open.clear();
    _matched.clear();
  }

  Future<void> _flip(int index) async {
    if (_busy || _matched.contains(index) || _open.contains(index)) return;

    setState(() => _open.add(index));

    final visible = _open.where((i) => !_matched.contains(i)).toList();
    if (visible.length < 2) return;

    final a = visible[visible.length - 2];
    final b = visible.last;
    final ok = _cards[a].keyValue == _cards[b].keyValue;

    if (ok) {
      setState(() {
        _matched.add(a);
        _matched.add(b);
        _score += 120 + _streak * 10;
        _streak++;
      });

      if (_matched.length == _cards.length) {
        await Future<void>.delayed(const Duration(milliseconds: 450));
        if (!mounted) return;

        final nextStart = (_set + 1) * 4;
        if (nextStart >= _vocab.length) {
          Navigator.pop(context, true);
        } else {
          setState(() {
            _set++;
            _prepare();
          });
        }
      }
      return;
    }

    setState(() {
      _busy = true;
      _streak = 0;
    });

    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    setState(() {
      _open.remove(a);
      _open.remove(b);
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF86E59B);
    final completedPairs = _set * 4 + _matched.length ~/ 2;

    return PremiumGameScaffold(
      eyebrow: 'MEMORY BATTLE',
      title: 'Family Match',
      subtitle:
          'Flip cards and connect the English family word with its meaning.',
      icon: Icons.grid_view_rounded,
      accent: accent,
      progress: (completedPairs / math.max(1, _vocab.length))
          .clamp(0.0, 1.0),
      score: _score,
      streak: _streak,
      onClose: () => Navigator.pop(context, false),
      child: PremiumGamePanel(
        accent: accent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BOARD ${_set + 1}',
              style: const TextStyle(
                color: Color(0xFF86E59B),
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                letterSpacing: .8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${_matched.length ~/ 2}/${_cards.length ~/ 2} pairs found',
              style: TextStyle(
                color: Brand.white.withOpacity(.56),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 13),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _cards.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.55,
                crossAxisSpacing: 9,
                mainAxisSpacing: 9,
              ),
              itemBuilder: (_, index) {
                final card = _cards[index];
                final open =
                    _open.contains(index) || _matched.contains(index);
                final matched = _matched.contains(index);

                return InkWell(
                  onTap: () => _flip(index),
                  borderRadius: BorderRadius.circular(18),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    decoration: BoxDecoration(
                      color: matched
                          ? accent.withOpacity(.13)
                          : open
                              ? const Color(0xFF18354B)
                              : Brand.white.withOpacity(.04),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: matched
                            ? accent
                            : open
                                ? accent.withOpacity(.38)
                                : Brand.white.withOpacity(.07),
                      ),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: open
                            ? Column(
                                key: ValueKey('open-$index'),
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    card.tag,
                                    style: const TextStyle(
                                      color: Color(0xFF86E59B),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    card.text,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Brand.white,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              )
                            : const Icon(
                                Icons.family_restroom_rounded,
                                key: ValueKey('closed'),
                                color: Color(0xFF86E59B),
                                size: 31,
                              ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CardData {
  final String keyValue;
  final String text;
  final String tag;

  const _CardData({
    required this.keyValue,
    required this.text,
    required this.tag,
  });
}
