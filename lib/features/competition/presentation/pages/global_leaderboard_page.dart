import 'package:flutter/material.dart';

import '../../../../core/theme/brand.dart';
import '../../../../shared/widgets/learning_background.dart';
import '../../models/competitive_models.dart';
import '../../services/competition_service.dart';

class GlobalLeaderboardPage extends StatefulWidget {
  const GlobalLeaderboardPage({super.key});

  @override
  State<GlobalLeaderboardPage> createState() =>
      _GlobalLeaderboardPageState();
}

class _GlobalLeaderboardPageState extends State<GlobalLeaderboardPage> {
  final CompetitionService _service = CompetitionService();
  late final Future<String> _seasonFuture;

  @override
  void initState() {
    super.initState();
    _seasonFuture = _service.currentSeasonId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const LearningBackground(),
          SafeArea(
            child: FutureBuilder<String>(
              future: _seasonFuture,
              builder: (context, seasonSnapshot) {
                if (seasonSnapshot.connectionState !=
                    ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Brand.mint,
                    ),
                  );
                }

                if (seasonSnapshot.hasError ||
                    (seasonSnapshot.data ?? '').isEmpty) {
                  return _ErrorView(
                    message:
                        'No fue posible cargar la temporada competitiva.',
                    onBack: () => Navigator.of(context).pop(),
                  );
                }

                final seasonId = seasonSnapshot.data!;

                return StreamBuilder<List<LeaderboardEntry>>(
                  stream: _service.watchGlobalLeaderboard(
                    seasonId: seasonId,
                  ),
                  builder: (context, leaderboardSnapshot) {
                    if (!leaderboardSnapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Brand.mint,
                        ),
                      );
                    }

                    final entries = leaderboardSnapshot.data!;

                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
                      children: [
                        _TopBar(
                          seasonId: seasonId,
                          onBack: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(height: 18),
                        _Podium(entries: entries.take(3).toList()),
                        const SizedBox(height: 18),
                        ...List.generate(entries.length, (index) {
                          return _RankingRow(
                            rank: index + 1,
                            entry: entries[index],
                          );
                        }),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String seasonId;
  final VoidCallback onBack;

  const _TopBar({
    required this.seasonId,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Brand.bgPanel.withOpacity(0.68),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Brand.white.withOpacity(0.10),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Brand.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ranking mundial',
                style: TextStyle(
                  color: Brand.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Temporada $seasonId',
                style: TextStyle(
                  color: Brand.mint.withOpacity(0.82),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.public_rounded,
          color: Brand.mint,
          size: 30,
        ),
      ],
    );
  }
}

class _Podium extends StatelessWidget {
  final List<LeaderboardEntry> entries;

  const _Podium({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Brand.bgPanel.withOpacity(0.55),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Brand.white.withOpacity(0.10)),
        ),
        child: Text(
          'Todavía no hay jugadores clasificados en esta temporada.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Brand.white.withOpacity(0.65),
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    final ordered = <LeaderboardEntry?>[
      entries.length > 1 ? entries[1] : null,
      entries.first,
      entries.length > 2 ? entries[2] : null,
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 22, 12, 16),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(0.58),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Brand.white.withOpacity(0.10)),
        boxShadow: Brand.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(3, (index) {
          final entry = ordered[index];
          final rank = index == 0
              ? 2
              : index == 1
                  ? 1
                  : 3;

          return Expanded(
            child: _PodiumPlayer(
              entry: entry,
              rank: rank,
              elevated: rank == 1,
            ),
          );
        }),
      ),
    );
  }
}

class _PodiumPlayer extends StatelessWidget {
  final LeaderboardEntry? entry;
  final int rank;
  final bool elevated;

  const _PodiumPlayer({
    required this.entry,
    required this.rank,
    required this.elevated,
  });

  @override
  Widget build(BuildContext context) {
    final color = rank == 1
        ? const Color(0xFFFFC94D)
        : rank == 2
            ? const Color(0xFFC8D0DD)
            : const Color(0xFFCE8B55);

    return Padding(
      padding: EdgeInsets.only(
        left: 4,
        right: 4,
        bottom: elevated ? 18 : 0,
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: elevated ? 34 : 29,
                backgroundColor: Brand.bgDeep,
                child: Text(
                  entry?.displayName.isNotEmpty == true
                      ? entry!.displayName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: color,
                    fontSize: elevated ? 29 : 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  width: 27,
                  height: 27,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Brand.bgPanel, width: 3),
                  ),
                  child: Center(
                    child: Text(
                      '$rank',
                      style: const TextStyle(
                        color: Brand.bgDeep,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            entry?.displayName ?? 'Vacante',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Brand.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            entry == null ? '—' : '${entry!.xp} XP',
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingRow extends StatelessWidget {
  final int rank;
  final LeaderboardEntry entry;

  const _RankingRow({
    required this.rank,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Brand.bgPanel.withOpacity(0.50),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Brand.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(
              '$rank',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Brand.mint,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 21,
            backgroundColor: Brand.bgDeep,
            child: Text(
              entry.displayName.isEmpty
                  ? '?'
                  : entry.displayName[0].toUpperCase(),
              style: const TextStyle(
                color: Brand.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Brand.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.countryCode} · ${entry.wins} victorias · mejor ${entry.bestScore}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Brand.white.withOpacity(0.48),
                    fontSize: 10.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${entry.xp} XP',
            style: const TextStyle(
              color: Brand.mint,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onBack;

  const _ErrorView({
    required this.message,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Brand.mint,
              size: 54,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Brand.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            TextButton(
              onPressed: onBack,
              child: const Text(
                'Volver',
                style: TextStyle(
                  color: Brand.mint,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
