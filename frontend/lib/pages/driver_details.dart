import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/drivers_career_results.dart';
import '../providers/driver_stats_provider.dart';
import '../utils/team_assets.dart';

class DriverCareerPage extends ConsumerWidget {
  final String driverName;
  final String driverId;
  final String nationality;
  final String dateOfBirth;

  const DriverCareerPage({
    super.key,
    required this.driverName,
    required this.driverId,
    required this.nationality,
    required this.dateOfBirth,
  });

  // Split name into first / last for the stacked display
  String get _firstName => driverName.split(' ').first;
  String get _lastName =>
      driverName.split(' ').length > 1 ? driverName.split(' ').last : '';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final careerAsync = ref.watch(resultsProvider);
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // ── RED GLOW TOP LEFT ──
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE10600).withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),



          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── TOP BAR ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Row(
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'DRIVER PROFILE',
                        style: GoogleFonts.orbitron(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white38,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── HERO SECTION ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.07),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Red left stripe
                        Container(
                          width: 4,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE10600),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                          ),
                        ),

                        // Driver image — fixed width, fills height
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: SizedBox(
                            width: 130,
                            child: TeamAssets.getDriverImage(driverId) != null
                                ? Image.network(
                              TeamAssets.getDriverImage(driverId)!,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              headers: const {'User-Agent': 'Mozilla/5.0'},
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.white.withValues(alpha: 0.03),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: Color(0xFFE10600),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => _driverFallback(),
                            )
                                : _driverFallback(),
                          ),
                        ),

                        // Vertical divider
                        Container(
                          width: 1,
                          color: Colors.white.withValues(alpha: 0.06),
                        ),

                        // Driver info
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _firstName.toUpperCase(),
                                  style: GoogleFonts.orbitron(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white38,
                                    letterSpacing: 2,
                                  ),
                                ),
                                Text(
                                  _lastName.toUpperCase(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.orbitron(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                    height: 1.05,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(width: 32, height: 2, color: const Color(0xFFE10600)),
                                const SizedBox(height: 12),
                                _MetaRow(icon: Icons.flag_outlined, text: nationality.toUpperCase()),
                                const SizedBox(height: 6),
                                _MetaRow(icon: Icons.cake_outlined, text: dateOfBirth),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── CONTENT ──
                Expanded(
                  child: careerAsync.when(
                    loading: () => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'LOADING CAREER DATA',
                            style: GoogleFonts.orbitron(
                              color: Colors.white24,
                              fontSize: 9,
                              letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 160,
                            child: LinearProgressIndicator(
                              minHeight: 2,
                              backgroundColor:
                              Colors.white.withValues(alpha: 0.05),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFE10600)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    error: (e, s) => Center(
                      child: Text(
                        'ERROR LOADING DATA',
                        style: GoogleFonts.orbitron(
                          color: Colors.white24,
                          fontSize: 9,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                    data: (stats) => ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      children: [

                        // ── PRIMARY STATS ROW ──
                        _GridStats(stats: stats),

                        const SizedBox(height: 12),

                        // ── TOTAL POINTS BANNER ──
                        _PointsBanner(value: stats.totalPoints.toStringAsFixed(0)),

                        const SizedBox(height: 28),

                        // ── SECTION: POINTS PER SEASON ──
                        _SectionLabel(label: 'POINTS PER SEASON'),
                        const SizedBox(height: 12),
                        _SeasonBarChart(pointsPerSeason: stats.pointsPerSeason),

                        const SizedBox(height: 28),

                        // ── SECTION: PERFORMANCE ──
                        _SectionLabel(label: 'PERFORMANCE'),
                        const SizedBox(height: 12),
                        _PerformanceCard(stats: stats),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _driverFallback() {
    return Container(
      color: Colors.transparent,
      child: const Icon(Icons.person, color: Colors.white12, size: 56),
    );
  }
}

// ── META ROW ──
class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFE10600), size: 11),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.rajdhani(
              fontSize: 11,
              color: Colors.white54,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ── SECTION LABEL ──
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 13,
          decoration: BoxDecoration(
            color: const Color(0xFFE10600),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.orbitron(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.white54,
            letterSpacing: 2.5,
          ),
        ),
      ],
    );
  }
}

// ── 2×2 STAT GRID ──
class _GridStats extends StatelessWidget {
  final DriverCareerStats stats;
  const _GridStats({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _StatTile(label: 'RACES', value: '${stats.totalRaces}'),
              const SizedBox(height: 10),
              _StatTile(label: 'PODIUMS', value: '${stats.podiums}'),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            children: [
              _StatTile(label: 'WINS', value: '${stats.wins}', accent: true),
              const SizedBox(height: 10),
              _StatTile(label: 'POLES', value: '${stats.poles}'),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final bool accent;
  const _StatTile({
    required this.label,
    required this.value,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: accent
            ? const Color(0xFFE10600).withValues(alpha: 0.09)
            : const Color(0xFF111111),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accent
              ? const Color(0xFFE10600).withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.orbitron(
              fontSize: 8,
              color: accent ? const Color(0xFFE10600).withValues(alpha: 0.8) : Colors.white30,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: accent ? Colors.white : Colors.white,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── POINTS BANNER ──
class _PointsBanner extends StatelessWidget {
  final String value;
  const _PointsBanner({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL POINTS',
                  style: GoogleFonts.orbitron(
                    fontSize: 9,
                    color: Colors.white30,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Career championship score',
                  style: GoogleFonts.rajdhani(
                    fontSize: 11,
                    color: Colors.white24,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.orbitron(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1.5,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 3),
                child: Text(
                  'PTS',
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFE10600),
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── PERFORMANCE CARD ──
class _PerformanceCard extends StatelessWidget {
  final DriverCareerStats stats;
  const _PerformanceCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final winRate = stats.totalRaces > 0
        ? stats.wins / stats.totalRaces
        : 0.0;
    final podiumRate = stats.totalRaces > 0
        ? stats.podiums / stats.totalRaces
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          _RateRow(
            label: 'WIN RATE',
            value: '${(winRate * 100).toStringAsFixed(1)}%',
            rate: winRate,
          ),
          const SizedBox(height: 20),
          _RateRow(
            label: 'PODIUM RATE',
            value: '${(podiumRate * 100).toStringAsFixed(1)}%',
            rate: podiumRate,
          ),
        ],
      ),
    );
  }
}

class _RateRow extends StatelessWidget {
  final String label;
  final String value;
  final double rate;
  const _RateRow({
    required this.label,
    required this.value,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.orbitron(
                fontSize: 9,
                color: Colors.white30,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.orbitron(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Stack(
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            FractionallySizedBox(
              widthFactor: rate.clamp(0.0, 1.0),
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFE10600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── SEASON BAR CHART ──
class _SeasonBarChart extends StatelessWidget {
  final Map<String, double> pointsPerSeason;
  const _SeasonBarChart({required this.pointsPerSeason});

  @override
  Widget build(BuildContext context) {
    final seasons = pointsPerSeason.keys.toList()..sort();
    final maxPoints =
    pointsPerSeason.values.fold(0.0, (a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: seasons.map((season) {
            final pts = pointsPerSeason[season] ?? 0;
            final barH = maxPoints > 0 ? (pts / maxPoints) * 90 : 0.0;
            final isMax = pts == maxPoints;
            final isMajor = pts > maxPoints * 0.7;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Points label
                  Text(
                    pts.toStringAsFixed(0),
                    style: GoogleFonts.orbitron(
                      fontSize: 7,
                      color: isMax
                          ? const Color(0xFFE10600)
                          : isMajor
                          ? Colors.white38
                          : Colors.white10,
                      fontWeight: isMax ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Bar
                  Container(
                    width: 16,
                    height: barH.toDouble(),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: isMax
                          ? const Color(0xFFE10600)
                          : const Color(0xFFE10600).withValues(alpha: isMajor ? 0.45 : 0.2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Season label
                  RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      season,
                      style: GoogleFonts.rajdhani(
                        fontSize: 9,
                        color: isMax ? Colors.white54 : Colors.white24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}