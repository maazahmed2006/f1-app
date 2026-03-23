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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final careerAsync = ref.watch(resultsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── BACK BUTTON ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12)),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── HERO DRIVER CARD ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.13)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE10600).withValues(alpha: 0.12),
                              blurRadius: 40,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [

                            // ── DRIVER IMAGE ──
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                bottomLeft: Radius.circular(24),
                              ),
                              child: SizedBox(
                                width: 140,
                                height: 160,
                                child: TeamAssets.getDriverImage(driverId) != null
                                    ? Image.network(
                                  TeamAssets.getDriverImage(driverId)!,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                  headers: const {'User-Agent': 'Mozilla/5.0'},
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.white.withValues(alpha: 0.04),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
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

                            // ── DRIVER INFO ──
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [

                                    // Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE10600).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: const Color(0xFFE10600).withValues(alpha: 0.4),
                                        ),
                                      ),
                                      child: Text(
                                        "CAREER STATS",
                                        style: GoogleFonts.orbitron(
                                          fontSize: 8,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFFE10600),
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    // Driver name
                                    Text(
                                      driverName.toUpperCase(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.orbitron(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 1,
                                        height: 1.2,
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    Container(
                                      height: 1,
                                      color: Colors.white.withValues(alpha: 0.08),
                                    ),

                                    const SizedBox(height: 12),

                                    // Nationality
                                    Row(
                                      children: [
                                        const Icon(Icons.flag_outlined,
                                            color: Color(0xFFE10600), size: 12),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            nationality.toUpperCase(),
                                            style: GoogleFonts.rajdhani(
                                              fontSize: 12,
                                              color: Colors.white60,
                                              letterSpacing: 1.2,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 6),

                                    // DOB
                                    Row(
                                      children: [
                                        const Icon(Icons.cake_outlined,
                                            color: Color(0xFFE10600), size: 12),
                                        const SizedBox(width: 6),
                                        Text(
                                          dateOfBirth,
                                          style: GoogleFonts.rajdhani(
                                            fontSize: 12,
                                            color: Colors.white60,
                                            letterSpacing: 1.2,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                            "LOADING CAREER DATA",
                            style: GoogleFonts.orbitron(
                              color: Colors.white38,
                              fontSize: 10,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: 200,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                minHeight: 3,
                                backgroundColor: Colors.white.withValues(alpha: 0.05),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFFE10600)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    error: (e, s) => Center(
                      child: Text(
                        "ERROR LOADING DATA",
                        style: GoogleFonts.orbitron(
                          color: Colors.white38,
                          fontSize: 10,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    data: (stats) => ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        Row(
                          children: [
                            _StatCard(label: "RACES", value: "${stats.totalRaces}"),
                            const SizedBox(width: 10),
                            _StatCard(label: "WINS", value: "${stats.wins}"),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _StatCard(label: "PODIUMS", value: "${stats.podiums}"),
                            const SizedBox(width: 10),
                            _StatCard(label: "POLES", value: "${stats.poles}"),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _FullStatCard(
                          label: "TOTAL POINTS",
                          value: stats.totalPoints.toStringAsFixed(0),
                        ),
                        const SizedBox(height: 24),
                        _SectionLabel(label: "POINTS PER SEASON"),
                        const SizedBox(height: 12),
                        _SeasonBarChart(pointsPerSeason: stats.pointsPerSeason),
                        const SizedBox(height: 24),
                        _SectionLabel(label: "PERFORMANCE"),
                        const SizedBox(height: 12),
                        _PerformanceCard(stats: stats),
                        const SizedBox(height: 24),
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
      width: 140,
      height: 160,
      color: Colors.white.withValues(alpha: 0.04),
      child: const Icon(Icons.person, color: Colors.white24, size: 48),
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
          height: 14,
          decoration: BoxDecoration(
            color: const Color(0xFFE10600),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.orbitron(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFE10600),
            letterSpacing: 2.5,
          ),
        ),
      ],
    );
  }
}

// ── HALF WIDTH STAT CARD ──
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.orbitron(
                    fontSize: 9,
                    color: Colors.white38,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: GoogleFonts.orbitron(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                    shadows: const [
                      Shadow(color: Colors.white, blurRadius: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── FULL WIDTH STAT CARD ──
class _FullStatCard extends StatelessWidget {
  final String label;
  final String value;
  const _FullStatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFE10600).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE10600).withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE10600).withValues(alpha: 0.1),
                blurRadius: 24,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "TOTAL POINTS",
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  color: Colors.white60,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.orbitron(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
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
        ? (stats.wins / stats.totalRaces * 100).toStringAsFixed(1)
        : "0.0";
    final podiumRate = stats.totalRaces > 0
        ? (stats.podiums / stats.totalRaces * 100).toStringAsFixed(1)
        : "0.0";

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Column(
            children: [
              _RateRow(
                label: "WIN RATE",
                value: "$winRate%",
                rate: stats.totalRaces > 0 ? stats.wins / stats.totalRaces : 0,
              ),
              const SizedBox(height: 18),
              _RateRow(
                label: "PODIUM RATE",
                value: "$podiumRate%",
                rate: stats.totalRaces > 0 ? stats.podiums / stats.totalRaces : 0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _RateRow({
    required String label,
    required String value,
    required double rate,
  }) {
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
                color: Colors.white38,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.orbitron(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            FractionallySizedBox(
              widthFactor: rate.clamp(0.0, 1.0),
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF4444), Color(0xFFE10600)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE10600).withValues(alpha: 0.5),
                      blurRadius: 6,
                    ),
                  ],
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: seasons.map((season) {
                final pts = pointsPerSeason[season] ?? 0;
                final barHeight = maxPoints > 0 ? (pts / maxPoints) * 100 : 0.0;
                final isMax = pts == maxPoints;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        pts.toStringAsFixed(0),
                        style: GoogleFonts.orbitron(
                          fontSize: 7,
                          color: isMax
                              ? const Color(0xFFE10600)
                              : Colors.white38,
                          fontWeight: isMax
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 18,
                        height: barHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: isMax
                                ? [
                              const Color(0xFFE10600),
                              const Color(0xFFFF4444),
                            ]
                                : [
                              const Color(0xFFE10600).withValues(alpha: 0.4),
                              const Color(0xFFE10600).withValues(alpha: 0.7),
                            ],
                          ),
                          boxShadow: isMax
                              ? [
                            BoxShadow(
                              color: const Color(0xFFE10600).withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ]
                              : [],
                        ),
                      ),
                      const SizedBox(height: 6),
                      RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          season,
                          style: GoogleFonts.rajdhani(
                            fontSize: 9,
                            color: isMax ? Colors.white60 : Colors.white24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}