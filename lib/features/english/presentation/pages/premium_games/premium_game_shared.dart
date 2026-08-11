import 'package:flutter/material.dart';

import '../../../../../core/theme/brand.dart';

class PremiumGameScaffold extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final double progress;
  final int score;
  final int streak;
  final Widget child;
  final VoidCallback onClose;

  const PremiumGameScaffold({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.progress,
    required this.score,
    required this.streak,
    required this.child,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).height < 760;

    return Scaffold(
      backgroundColor: Brand.bgDeep,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white70,
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: Colors.white10,
                        valueColor: AlwaysStoppedAnimation(accent),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$score',
                    style: const TextStyle(
                      color: Brand.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (streak > 1) ...[
                    const SizedBox(width: 7),
                    Text(
                      '🔥$streak',
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  18,
                  compact ? 12 : 18,
                  18,
                  28,
                ),
                children: [
                  Container(
                    padding: EdgeInsets.all(compact ? 16 : 19),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accent.withOpacity(.18),
                          const Color(0xFF10263D),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: accent.withOpacity(.28)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(icon, color: Brand.bgDeep, size: 28),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                eyebrow,
                                style: TextStyle(
                                  color: accent,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: .9,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                title,
                                style: const TextStyle(
                                  color: Brand.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  color: Brand.white.withOpacity(.58),
                                  fontSize: 11.8,
                                  height: 1.3,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  child,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PremiumGamePanel extends StatelessWidget {
  final Color accent;
  final Widget child;

  const PremiumGamePanel({
    super.key,
    required this.accent,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D2135),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withOpacity(.18)),
      ),
      child: child,
    );
  }
}

class GameFeedback extends StatelessWidget {
  final bool correct;
  final String correctText;

  const GameFeedback({
    super.key,
    required this.correct,
    required this.correctText,
  });

  @override
  Widget build(BuildContext context) {
    final color = correct ? const Color(0xFF66E6A3) : Colors.redAccent;
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withOpacity(.09),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: color.withOpacity(.30)),
      ),
      child: Row(
        children: [
          Icon(
            correct ? Icons.auto_awesome_rounded : Icons.lightbulb_rounded,
            color: correct ? color : const Color(0xFFFFCF65),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              correct ? 'Nice! Keep the rhythm.' : 'Correct: $correctText',
              style: const TextStyle(
                color: Brand.white,
                fontSize: 12.4,
                height: 1.3,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GameNextButton extends StatelessWidget {
  final bool last;
  final VoidCallback onTap;

  const GameNextButton({
    super.key,
    required this.last,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      height: 54,
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: Brand.mint,
          foregroundColor: Brand.bgDeep,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        icon: Icon(
          last ? Icons.emoji_events_rounded : Icons.arrow_forward_rounded,
        ),
        label: Text(
          last ? 'Finish game' : 'Next round',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class GameOption extends StatelessWidget {
  final String text;
  final Color accent;
  final bool selected;
  final bool correct;
  final bool wrong;
  final VoidCallback? onTap;

  const GameOption({
    super.key,
    required this.text,
    required this.accent,
    required this.selected,
    required this.correct,
    required this.wrong,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var bg = Brand.white.withOpacity(.035);
    var border = Brand.white.withOpacity(.07);
    var icon = Icons.circle_outlined;
    var iconColor = Brand.white.withOpacity(.25);

    if (selected && !correct && !wrong) {
      bg = accent.withOpacity(.11);
      border = accent.withOpacity(.48);
      icon = Icons.radio_button_checked_rounded;
      iconColor = accent;
    }
    if (correct) {
      bg = const Color(0xFF66E6A3).withOpacity(.11);
      border = const Color(0xFF66E6A3);
      icon = Icons.check_circle_rounded;
      iconColor = const Color(0xFF66E6A3);
    }
    if (wrong) {
      bg = Colors.redAccent.withOpacity(.10);
      border = Colors.redAccent.withOpacity(.65);
      icon = Icons.cancel_rounded;
      iconColor = Colors.redAccent;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 19),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Brand.white,
                    fontSize: 12.8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
