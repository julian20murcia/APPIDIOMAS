import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/theme/brand.dart';
import '../../../data/english_level_1_curriculum.dart';
import '../../../models/english_lesson.dart';
import 'premium_game_shared.dart';

class PrepositionSceneGame extends StatefulWidget {
  final EnglishLesson lesson;
  const PrepositionSceneGame({super.key, required this.lesson});

  @override
  State<PrepositionSceneGame> createState() => _PrepositionSceneGameState();
}

class _PrepositionSceneGameState extends State<PrepositionSceneGame> {
  int _round = 0;
  int _score = 0;
  int _streak = 0;
  bool _answered = false;
  bool _correct = false;
  Offset _objectPosition = const Offset(145, 210);

  List<dynamic> get _vocab =>
      englishLevel1Vocabulary[widget.lesson.number] ?? const [];
  dynamic get _pair => _vocab[_round % _vocab.length];

  _Zone _targetZone(String english) {
    final s = english.toLowerCase();
    if (s.contains('left')) return _Zone.left;
    if (s.contains('right')) return _Zone.right;
    if (s.contains('under') || s == 'below') return _Zone.under;
    if (s.contains('on top') || s == 'on') return _Zone.onTop;
    if (s.contains('behind')) return _Zone.behind;
    if (s.contains('in front')) return _Zone.front;
    if (s == 'in') return _Zone.inside;
    if (s.contains('outside')) return _Zone.outside;
    if (s.contains('between')) return _Zone.between;
    if (s.contains('near') || s.contains('next to')) return _Zone.near;
    if (s.contains('far')) return _Zone.far;
    if (s.contains('opposite')) return _Zone.opposite;
    return _Zone.near;
  }

  void _drop(_Zone zone) {
    if (_answered) return;
    final ok = zone == _targetZone(_pair.english as String);
    setState(() {
      _answered = true;
      _correct = ok;
      _objectPosition = _positionFor(zone);
      if (ok) {
        _score += 130 + _streak * 15;
        _streak++;
      } else {
        _streak = 0;
      }
    });
  }

  Offset _positionFor(_Zone zone) {
    switch (zone) {
      case _Zone.left:
        return const Offset(30, 145);
      case _Zone.right:
        return const Offset(258, 145);
      case _Zone.under:
        return const Offset(145, 245);
      case _Zone.onTop:
        return const Offset(145, 64);
      case _Zone.behind:
        return const Offset(145, 120);
      case _Zone.front:
        return const Offset(145, 175);
      case _Zone.inside:
        return const Offset(145, 145);
      case _Zone.outside:
        return const Offset(270, 45);
      case _Zone.between:
        return const Offset(145, 145);
      case _Zone.near:
        return const Offset(220, 170);
      case _Zone.far:
        return const Offset(285, 255);
      case _Zone.opposite:
        return const Offset(145, 26);
    }
  }

  void _next() {
    if (_round >= _vocab.length - 1) {
      Navigator.pop(context, true);
      return;
    }
    setState(() {
      _round++;
      _answered = false;
      _correct = false;
      _objectPosition = const Offset(145, 210);
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFFB89CFF);
    final target = _targetZone(_pair.english as String);

    return PremiumGameScaffold(
      eyebrow: 'SCENE WORLD',
      title: 'Place It Right',
      subtitle:
          'Drag the object into the scene. Learn prepositions by physically placing things.',
      icon: Icons.view_in_ar_rounded,
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
              'PLACE IT: ${_pair.english}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Brand.white,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Drag the blue object to the correct zone.',
              style: TextStyle(
                color: Brand.white.withOpacity(.48),
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _scene(target),
            if (_answered) ...[
              GameFeedback(
                correct: _correct,
                correctText: _pair.english as String,
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

  Widget _scene(_Zone target) {
    return SizedBox(
      height: 330,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF112A42),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Brand.white.withOpacity(.06)),
              ),
            ),
          ),

          // Main furniture / anchors
          const Positioned(
            left: 105,
            top: 116,
            child: Icon(
              Icons.table_restaurant_rounded,
              color: Colors.white70,
              size: 90,
            ),
          ),
          const Positioned(
            left: 35,
            top: 150,
            child: Icon(
              Icons.chair_alt_rounded,
              color: Colors.white38,
              size: 60,
            ),
          ),
          const Positioned(
            right: 28,
            top: 145,
            child: Icon(
              Icons.door_front_door_rounded,
              color: Colors.white38,
              size: 68,
            ),
          ),

          ..._zoneTargets(),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 260),
            left: _objectPosition.dx,
            top: _objectPosition.dy,
            child: Draggable<String>(
              data: 'object',
              feedback: _petToken(),
              childWhenDragging: Opacity(
                opacity: .25,
                child: _petToken(),
              ),
              child: _petToken(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _zoneTargets() {
    final zones = <(_Zone, double, double, String)>[
      (_Zone.left, 15, 120, 'LEFT'),
      (_Zone.right, 270, 120, 'RIGHT'),
      (_Zone.onTop, 120, 30, 'ON'),
      (_Zone.under, 120, 245, 'UNDER'),
      (_Zone.front, 120, 190, 'FRONT'),
      (_Zone.behind, 120, 92, 'BEHIND'),
      (_Zone.near, 225, 185, 'NEAR'),
      (_Zone.far, 275, 260, 'FAR'),
      (_Zone.opposite, 120, 0, 'OPPOSITE'),
      (_Zone.outside, 275, 25, 'OUTSIDE'),
      (_Zone.between, 120, 142, 'BETWEEN'),
      (_Zone.inside, 150, 142, 'IN'),
    ];

    return zones.map((item) {
      return Positioned(
        left: item.$2,
        top: item.$3,
        child: DragTarget<String>(
          onAcceptWithDetails: (_) => _drop(item.$1),
          builder: (_, candidate, __) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 58,
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: candidate.isNotEmpty
                    ? const Color(0xFFB89CFF).withOpacity(.18)
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: candidate.isNotEmpty
                      ? const Color(0xFFB89CFF)
                      : Colors.white.withOpacity(.03),
                ),
              ),
              child: Text(
                item.$4,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: candidate.isNotEmpty
                      ? const Color(0xFFB89CFF)
                      : Colors.white12,
                  fontSize: 7.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            );
          },
        ),
      );
    }).toList();
  }

  Widget _petToken() {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: const Color(0xFFB89CFF),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.28),
              blurRadius: 12,
            ),
          ],
        ),
        child: const Icon(
          Icons.pets_rounded,
          color: Brand.bgDeep,
          size: 29,
        ),
      ),
    );
  }
}

enum _Zone {
  left,
  right,
  under,
  onTop,
  behind,
  front,
  inside,
  outside,
  between,
  near,
  far,
  opposite,
}
