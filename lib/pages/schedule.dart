import 'dart:async';
import 'dart:ui';
import 'package:f1_app/providers/yearListProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/season_providers.dart';
import '../models/season_model.dart';
import '../models/winners_model.dart';
import '../utils/countries_flag.dart';

DateTime? _parseRaceDateTime(String date, String? time) {
  try {
    final t = (time != null && time.isNotEmpty) ? time : '00:00:00Z';
    final raw = t.endsWith('Z') ? t : '${t}Z';
    return DateTime.parse('${date}T$raw').toLocal();
  } catch (_) {
    return null;
  }
}


class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  static final List<String> _years = [
    for (int y = 1950; y <= DateTime.now().year; y++) y.toString()
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(scheduleDataProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding:  EdgeInsets.only(left: 10 , right: 10),
            child: Row(
              children: [
                Text(
                  "RACE SCHEDULE",
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: const Color(0xFFE10600),
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                DropdownMenu<String>(
                  hintText: ref.watch(selectedYearProvider),
                  menuHeight: 400,
                  width: 120,
                  textStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                  inputDecorationTheme: InputDecorationTheme(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    constraints: const BoxConstraints(maxHeight: 36),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: const Color(0xFFE10600).withValues(alpha: 0.9)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: const Color(0xFFE10600).withValues(alpha: 0.4)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE10600)),
                    ),
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    filled: true,
                  ),
                  dropdownMenuEntries: _years.map((year) {
                    return DropdownMenuEntry<String>(
                      value: year,
                      label: year,
                      style: ButtonStyle(
                        textStyle: WidgetStateProperty.all(
                          const TextStyle(fontSize: 12, letterSpacing: 1.2),
                        ),
                      ),
                    );
                  }).toList(),
                  onSelected: (String? selected) {
                    if (selected != null) {   // ✅ null-safe
                      ref.read(selectedYearProvider.notifier).state = selected;
                    }
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: scheduleAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFFE10600)),
              ),
              error: (err, stack) => Center(
                child: Text('$err', style: Theme.of(context).textTheme.bodyMedium),
              ),
              data: (data) {
                final races   = data.races;
                final winners = data.winners;
                final now = DateTime.now();
                final nextRaceIndex = races.indexWhere((r) {
                  final dt = _parseRaceDateTime(r.date, r.time);
                  return dt != null && dt.isAfter(now);
                });
            
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SizedBox(height: 16),
                    ...List.generate(races.length, (index) {
                      final winner = index < winners.length ? winners[index] : null;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ExpandableRaceCard(
                          race: races[index],
                          winner: winner,
                          isNextRace: index == nextRaceIndex,
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      )
    );
  }
}

class _ExpandableRaceCard extends StatefulWidget {
  final Season  race;
  final Result? winner;
  final bool    isNextRace; // ← add this
  const _ExpandableRaceCard({
    required this.race,
    this.winner,
    this.isNextRace = false, // ← default false
  });

  @override
  State<_ExpandableRaceCard> createState() => _ExpandableRaceCardState();
}

class _ExpandableRaceCardState extends State<_ExpandableRaceCard> {
  bool _expanded      = false;
  bool _isLive        = false;

  DateTime? _raceDateTime;
  bool _isCompleted   = false;
  bool _showCountdown = false;

  @override
  void initState() {
    super.initState();
    _raceDateTime = _parseRaceDateTime(widget.race.date, widget.race.time);
    if (_raceDateTime != null) {
      final now = DateTime.now();
      _isCompleted   = _raceDateTime!.isBefore(now);
      final diff     = _raceDateTime!.difference(now);

      _showCountdown = !_isCompleted &&
          (widget.isNextRace || diff.inDays < 3);
    }
  }

  @override
  Widget build(BuildContext context) {
    final race   = widget.race;
    final winner = widget.winner;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [

          // ── LAYER 1: Flag image fills the entire card background ──
          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (rect) => LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withValues(alpha: 0.6),
                  Colors.transparent,
                ],
                stops: const [0.2, 0.8],
              ).createShader(rect),
              blendMode: BlendMode.overlay,
              child: Flags().getFlag(race.country) != null
                  ? Image.network(
                "${Flags().getFlag(race.country)}",
                fit: BoxFit.cover,
                alignment: Alignment.centerRight, // flag shows on right side
              )
                  : const SizedBox.shrink(),
            ),
          ),

          // ── LAYER 2: Dark tint so flag doesn't overpower content ──
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 1), // dark on left (text side)
                    Colors.black.withValues(alpha: 0.3), // lighter on right (flag side)
                  ],
                ),
              ),
            ),
          ),

          // ── LAYER 3: Frosted glass ON TOP of the flag ──
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06), // glass tint
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),

              // ── ALL YOUR EXISTING CONTENT GOES HERE (unchanged) ──
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE10600).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFE10600).withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            "R${race.round}",
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: const Color(0xFFE10600),
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                race.raceName,
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      color: Colors.white38, size: 13),
                                  const SizedBox(width: 4),
                                  Text(
                                    race.country,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.white60),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (_isCompleted)
                                _completedBadge()
                              else if (_showCountdown)
                                _upcomingBadge(),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  color: Colors.white38, size: 13),
                              const SizedBox(height: 10),
                              Text(
                                race.date,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(color: Colors.white60),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_showCountdown && _raceDateTime != null && !_isLive) ...[
                    Divider(height: 1, color: Colors.white.withValues(alpha: 0.07)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                      child: Center(
                        child: RaceCountdown(
                          raceDateTime: _raceDateTime!,
                          onLive: () => setState(() => _isLive = true),
                        ),
                      ),
                    ),
                  ],

                  Divider(height: 1, color: Colors.white.withValues(alpha: 0.07)),

                  GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "DETAILS",
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white38,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          AnimatedRotation(
                            turns: _expanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white38,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _expanded
                        ? Column(
                      children: [
                        Divider(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.07)),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _detailRow(context,
                                  Icons.emoji_events_outlined, "WINNER",
                                  winner != null
                                      ? "${winner.givenName} ${winner.lastName}"
                                      : "N/A"),
                              const SizedBox(height: 14),
                              _detailRow(context, Icons.loop, "LAPS",
                                  winner != null ? winner.laps : "N/A"),
                              const SizedBox(height: 14),
                              _detailRow(context, Icons.timer_outlined,
                                  "FASTEST LAP",
                                  winner != null
                                      ? "Lap ${winner.fastestLap}"
                                      : "N/A"),
                            ],
                          ),
                        ),
                      ],
                    )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _completedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE10600).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE10600).withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.check_circle_outline, color: Color(0xFFE10600), size: 11),
          SizedBox(width: 4),
          Text(
            "COMPLETED",
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: Color(0xFFE10600),
              letterSpacing: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _upcomingBadge() {
    if (_isLive) return _LiveBadge();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PulseDot(),
        const SizedBox(width: 5),
        const Text(
          "UPCOMING",
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: Color(0xFF00C853),
            letterSpacing: 1.8,
          ),
        ),
      ],
    );
  }

  Widget _detailRow(BuildContext context, IconData icon, String label,
      String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFE10600), size: 16),
        const SizedBox(width: 10),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.white38,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Race Countdown ────────────────────────────────────────────────────────────

class RaceCountdown extends StatefulWidget {
  final DateTime      raceDateTime;
  final VoidCallback? onLive;
  const RaceCountdown({super.key, required this.raceDateTime, this.onLive});

  @override
  State<RaceCountdown> createState() => _RaceCountdownState();
}

class _RaceCountdownState extends State<RaceCountdown> {
  Timer?   _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final r = widget.raceDateTime.difference(DateTime.now());
    if (!mounted) return;
    if (r.isNegative) {
      _timer?.cancel();
      widget.onLive?.call();
    } else {
      setState(() => _remaining = r);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d =  _remaining.inDays;
    final h = _remaining.inHours.remainder(24);
    final m = _remaining.inMinutes.remainder(60);
    final s = _remaining.inSeconds.remainder(60);

    return FittedBox(                          // ← wrap here
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (d > 0) ...[
            _TimeUnit(value: d, label: "DAY"),
            _BlinkingColon(),
          ],
          _TimeUnit(value: h, label: "HRS"),
          _BlinkingColon(),
          _TimeUnit(value: m, label: "MIN"),
          _BlinkingColon(),
          _TimeUnit(value: s, label: "SEC"),
        ],
      ),
    );
  }
}

// ── Live Badge ────────────────────────────────────────────────────────────────

class _LiveBadge extends StatefulWidget {
  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _scale;
  late final Animation<double>   _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat();
    _scale   = Tween<double>(begin: 0.6, end: 1.6)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _opacity = Tween<double>(begin: 0.9, end: 0.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE10600).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: const Color(0xFFE10600).withValues(alpha: 0.4), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE10600).withValues(alpha: 0.25),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, __) => Transform.scale(
                    scale: _scale.value,
                    child: Opacity(
                      opacity: _opacity.value,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFFE10600), width: 1.5),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE10600),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            "LIVE",
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFFE10600),
              letterSpacing: 4,
              shadows: [
                Shadow(color: Color(0xFFE10600), blurRadius: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Time Unit ─────────────────────────────────────────────────────────────────

class _TimeUnit extends StatelessWidget {
  final int    value;
  final String label;
  const _TimeUnit({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final str = value.toString().padLeft(2, '0');
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6E0502).withValues(alpha: 0),

              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _AnimatedDigit(digit: int.parse(str[0])),
                  const SizedBox(width: 1),
                  _AnimatedDigit(digit: int.parse(str[1])),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.6),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// ── Animated Digit ────────────────────────────────────────────────────────────

class _AnimatedDigit extends StatefulWidget {
  final int digit;
  const _AnimatedDigit({required this.digit});

  @override
  State<_AnimatedDigit> createState() => _AnimatedDigitState();
}

class _AnimatedDigitState extends State<_AnimatedDigit>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _slideOut;
  late Animation<double>   _slideIn;
  late Animation<double>   _fadeOut;
  late Animation<double>   _fadeIn;

  int _displayed = 0;
  int _incoming  = 0;

  @override
  void initState() {
    super.initState();
    _displayed = widget.digit;
    _incoming  = widget.digit;
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _buildAnimations();
    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) setState(() => _displayed = _incoming);
        _ctrl.reset();
      }
    });
  }

  void _buildAnimations() {
    _slideOut = Tween<double>(begin: 0, end: -16).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _fadeOut  = Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut)));
    _slideIn  = Tween<double>(begin: 16, end: 0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _fadeIn   = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut)));
  }

  @override
  void didUpdateWidget(_AnimatedDigit old) {
    super.didUpdateWidget(old);
    if (old.digit != widget.digit) {
      if (_ctrl.isAnimating) {
        _ctrl.stop();
        _displayed = _incoming;
        _ctrl.reset();
      }
      _incoming = widget.digit;
      _ctrl.forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 40,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            if (!_ctrl.isAnimating) {
              return Center(
                child: Text(
                  '$_incoming',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              );
            }
            return Stack(
              alignment: Alignment.center,
              children: [
                Transform.translate(
                  offset: Offset(0, _slideOut.value),
                  child: Opacity(
                    opacity: _fadeOut.value.clamp(0.0, 1.0),
                    child: Text('$_displayed', style: _digitStyle),
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, _slideIn.value),
                  child: Opacity(
                    opacity: _fadeIn.value.clamp(0.0, 1.0),
                    child: Text('$_incoming', style: _digitStyle),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

const _digitStyle = TextStyle(
  fontSize: 40,
  fontWeight: FontWeight.w900,
  fontFamily: 'monospace',
  color: Color(0xFFE10600),
  height: 1,
  shadows: [
    Shadow(color: Color(0xFFE10600), blurRadius: 5),
  ],
);

// ── Blinking Colon ────────────────────────────────────────────────────────────

class _BlinkingColon extends StatefulWidget {
  @override
  State<_BlinkingColon> createState() => _BlinkingColonState();
}

class _BlinkingColonState extends State<_BlinkingColon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.2, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 5, right: 5),
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _dot(_anim.value),
            const SizedBox(height: 5),
            _dot(_anim.value),
          ],
        ),
      ),
    );
  }

  Widget _dot(double opacity) => Container(
    width: 10,
    height: 7.5,
    decoration: BoxDecoration(
      color: const Color(0xFFE10600).withValues(alpha: opacity),
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFE10600).withValues(alpha: (opacity * 0.9)),
          blurRadius: 8,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: const Color(0xFFE10600).withValues(alpha:(opacity * 0.4)),
          blurRadius: 16,
          spreadRadius: 3,
        ),
      ],
    ),
  );
}

// ── Pulsing Green Dot ─────────────────────────────────────────────────────────

class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _scale;
  late final Animation<double>   _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
    _scale   = Tween<double>(begin: 0.7, end: 1.5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _opacity = Tween<double>(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 12,
      height: 12,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Transform.scale(
              scale: _scale.value,
              child: Opacity(
                opacity: _opacity.value,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: const Color(0xFF00C853), width: 1.5),
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF00C853),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}