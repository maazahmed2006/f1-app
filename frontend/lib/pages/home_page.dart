import 'dart:ui';
import 'package:f1_app/pages/schedule.dart';
import 'package:f1_app/pages/video_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/home_page_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    final homeAsync = ref.watch(homeDataProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: homeAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFE10600)),
        ),
        error: (err, stack) => Center(
          child: Text(
            '$err',
            style: GoogleFonts.rajdhani(color: Colors.white60, fontSize: 14),
          ),
        ),
        data: (data) {
          int i = 0;
          var firstRace = data.races.isNotEmpty ? data.races[i] : null;
          dynamic raceTime;
          dynamic raceEnd;
          dynamic currentTime;
          final constructors = data.constructorStandings;
          final drivers = data.driverStandings;
          while (true) {
            if (firstRace == null) break;
            raceTime = DateTime.parse(
              '${firstRace.date}T${firstRace.time}',
            ).toLocal();
            raceEnd = raceTime.add(const Duration(hours: 2));
            currentTime = DateTime.now();
            if (currentTime.isAfter(raceTime)) {
              i = i + 1;
              firstRace = i < data.races.length ? data.races[i] : null;
            } else {
              break;
            }
          }
          final timer = firstRace!= null ? DateTime.tryParse(
            '${firstRace.date}T${firstRace.time}'
          )?.toLocal() : null ;

          return ListView(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
            children: [
              _SectionLabel(label: "F1 2026 OPENING TITLES"),
              const SizedBox(height: 12),
              ClipRRect(
                child: _YoutubeThumbnailCard(videoId: 'JkkWXl8VohQ'),
              ),

              const SizedBox(height: 28),

              // ── NEXT RACE ──
              _SectionLabel(label: "NEXT RACE"),
              const SizedBox(height: 12),

              if (firstRace != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.transparent.withValues(alpha: 0.05)),
                      ),
                      child: Stack(
                        children: [
                          // ── CONTENT (unchanged) ──
                          Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children:
                                  [
                                    _StatusBadge(
                                    currentTime: currentTime,
                                    raceTime: raceTime,
                                    raceEnd: raceEnd,
                                    round: firstRace.round,
                                  ),

                                  ],
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  firstRace.raceName.toUpperCase(),
                                  style: GoogleFonts.orbitron(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  firstRace.circuitName,
                                  style: GoogleFonts.rajdhani(
                                    fontSize: 14,
                                    color: Colors.white54,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Divider(color: Colors.white.withValues(alpha: 0.08)),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _IconLabel(
                                      icon: Icons.location_on_outlined,
                                      label: firstRace.country,
                                    ),
                                    _IconLabel(
                                      icon: Icons.calendar_today_outlined,
                                      label: firstRace.date,
                                    ),
                                  ],
                                ),
                                timer != null && currentTime.isBefore(raceTime)
                                    ? Column(
                                  children: [
                                    const SizedBox(height: 16),
                                    Divider(color: Colors.white.withValues(alpha: 0.08)),
                                    const SizedBox(height: 20),
                                    RaceCountdown(raceDateTime: timer),
                                  ],
                                )
                                    : const SizedBox.shrink(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 28),

              // ── CONSTRUCTOR STANDINGS ──
              _SectionLabel(label: "CONSTRUCTOR STANDINGS"),
              const SizedBox(height: 12),
              _FrostedCard(
                child: Column(
                  children: List.generate(constructors.length, (index) {
                    final s = constructors[index];
                    final isLast = index == constructors.length - 1;
                    return Column(
                      children: [
                        _StandingRow(
                          position: s.position,
                          primaryText: s.constructor.constructorName,
                          secondaryText: s.constructor.nationality,
                          points: s.points,
                          wins: s.wins,
                        ),
                        if (!isLast)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Divider(
                              color: Colors.white.withValues(alpha: 0.07),
                            ),
                          )
                        else
                          const SizedBox(height: 4),
                      ],
                    );
                  }),
                ),
              ),

              const SizedBox(height: 28),

              // ── DRIVER STANDINGS ──
              _SectionLabel(label: "DRIVERS STANDINGS"),
              const SizedBox(height: 12),
              _FrostedCard(
                child: Column(
                  children: List.generate(drivers.length, (index) {
                    final driver = drivers[index];
                    final isLast = index == drivers.length - 1;
                    return Column(
                      children: [
                        _StandingRow(
                          position: driver.position,
                          primaryText:
                              '${driver.givenName} ${driver.familyName}',
                          secondaryText: driver.nationality,
                          points: driver.points,
                          wins: driver.wins,
                        ),
                        if (!isLast)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Divider(
                              color: Colors.white.withValues(alpha: 0.07),
                            ),
                          )
                        else
                          const SizedBox(height: 4),
                      ],
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
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
          height: 16,
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

// ── STATUS BADGE ──
class _StatusBadge extends StatelessWidget {
  final dynamic currentTime, raceTime, raceEnd;
  final String round;
  const _StatusBadge({
    required this.currentTime,
    required this.raceTime,
    required this.raceEnd,
    required this.round,
  });

  @override
  Widget build(BuildContext context) {
    String label;
    if (currentTime.isAfter(raceTime) && currentTime.isBefore(raceEnd)) {
      label = "● LIVE NOW";
    } else if (currentTime.isAfter(raceTime)) {
      label = "COMPLETED";
    } else {
      label = "ROUND $round";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE10600).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFFE10600).withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.orbitron(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFE10600),
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

// ── ICON + LABEL ROW ──
class _IconLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _IconLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 13),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.rajdhani(
            fontSize: 13,
            color: Colors.white54,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

// ── REUSABLE STANDING ROW ──
class _StandingRow extends StatelessWidget {
  final String position;
  final String primaryText;
  final String secondaryText;
  final String points;
  final String wins;

  const _StandingRow({
    required this.position,
    required this.primaryText,
    required this.secondaryText,
    required this.points,
    required this.wins,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Position
        SizedBox(
          width: 28,
          child: Text(
            position,
            style: GoogleFonts.orbitron(
              fontSize: 12,
              color: Colors.white24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        // Red accent bar
        Container(
          width: 3,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFE10600),
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        const SizedBox(width: 12),

        // Name + subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                primaryText.toUpperCase(),
                style: GoogleFonts.orbitron(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                secondaryText,
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  color: Colors.white38,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),

        // Points + Wins
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "$points PTS",
              style: GoogleFonts.orbitron(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              "$wins WINS",
              style: GoogleFonts.rajdhani(
                fontSize: 12,
                color: Colors.white38,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── FROSTED GLASS CARD ──
class _FrostedCard extends StatelessWidget {
  final Widget child;
  const _FrostedCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ── YOUTUBE THUMBNAIL CARD ──
class _YoutubeThumbnailCard extends StatelessWidget {
  final String videoId;
  const _YoutubeThumbnailCard({required this.videoId});

  void _openVideoPlayer(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            YoutubePlayerScreen(videoId: videoId,), // ← use videoId, not hardcoded
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0, 1);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          final tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openVideoPlayer(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                'https://i.ytimg.com/vi/Sks_fMr2Yss/sddefault.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.black,
                  child: const Icon(
                    Icons.video_library,
                    color: Colors.white30,
                    size: 48,
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE10600).withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE10600).withValues(alpha: 0.5),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 12,
                child: Row(
                  children: [
                    const Icon(
                      Icons.touch_app_outlined,
                      color: Colors.white38,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'TAP TO PLAY',
                      style: GoogleFonts.orbitron(
                        fontSize: 9,
                        color: Colors.white38,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
