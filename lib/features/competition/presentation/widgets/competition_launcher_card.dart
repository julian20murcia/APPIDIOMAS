import 'package:flutter/material.dart';

import '../../../../core/theme/brand.dart';
import '../pages/competitive_challenge_page.dart';
import '../pages/global_leaderboard_page.dart';

class CompetitionLauncherCard extends StatelessWidget {
  final int lessonNumber;

  const CompetitionLauncherCard({
    super.key,
    required this.lessonNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(0.62),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Brand.cyan.withOpacity(0.30)),
        boxShadow: Brand.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Brand.cyan.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: Brand.cyan.withOpacity(0.36)),
                ),
                child: const Icon(
                  Icons.public_rounded,
                  color: Brand.cyan,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Arena mundial',
                      style: TextStyle(
                        color: Brand.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Compite con la lección $lessonNumber y sube en la clasificación semanal.',
                      style: TextStyle(
                        color: Brand.white.withOpacity(0.58),
                        fontSize: 12,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CompetitiveChallengePage(
                            lessonNumber: lessonNumber,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.sports_esports_rounded),
                    label: const Text(
                      'Competir',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Brand.mint,
                      foregroundColor: Brand.bgDeep,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              SizedBox(
                width: 52,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const GlobalLeaderboardPage(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: Brand.cyan,
                    side: BorderSide(color: Brand.cyan.withOpacity(0.35)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  child: const Icon(Icons.leaderboard_rounded),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
