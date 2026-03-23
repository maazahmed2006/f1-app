import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/constructor_provider.dart';
import '../providers/driver_standing_provider.dart';
import '../providers/yearListProvider.dart';
import '../utils/team_assets.dart';

class StandingsScreen extends ConsumerStatefulWidget {
  const StandingsScreen({super.key});

  @override
  ConsumerState<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends ConsumerState<StandingsScreen> {
  int _selectedTab = 0;
  static final List<String> _years = [
    for (int i = 1950 ; i<=DateTime.now().year ; i++)
      i.toString()
  ];

  @override
  Widget build(BuildContext context) {
    final driverAsync = ref.watch(driverStandingsProvider);
    final constructorAsync = ref.watch(constructorStandingsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16 , right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "STANDINGS",
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: const Color(0xFFE10600),
                    letterSpacing: 2,
                  ),
                ),
                DropdownMenu<String>(
                    hintText: ref.watch(selectedYearStandingsProvider).toString(),
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
                        horizontal: 10,
                        vertical: 6,
                      ),
                      constraints: const BoxConstraints(maxHeight: 36),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: const Color(0xFFE10600).withValues(alpha: 0.9),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: const Color(0xFFE10600).withValues(alpha: 0.4),
                        ),
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
                      ref.read(selectedYearStandingsProvider.notifier).state = selected;
                    },
                  ),
              ],
            ),
          ),
          // ── REST OF YOUR CODE STAYS EXACTLY THE SAME ──
          const SizedBox(height: 15),
          // ... tab buttons, expanded content etc
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        _tabButton("DRIVERS", 0),
                        _tabButton("CONSTRUCTORS", 1),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5,),
              Expanded(
                child: _selectedTab == 0
                    ? driverAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE10600)),
                  ),
                  error: (err, stack) => Center(
                    child: Text(
                      "Error loading driver standings",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  data: (drivers) => drivers.isEmpty ?
                  const Center(
                    child: Text(
                      "NO STANDINGS AVAILABLE\nFOR THIS SEASON",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ) :ListView.separated(
                    itemCount: drivers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final d = drivers[index];
                      final standing = index+1;
                      final driverImageUrl = TeamAssets.getDriverImage(d.driverId);

                      return _FrostedCard(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                            // ── POSITION ──
                            SizedBox(
                              width: 28,
                              child: Text(
                                d.position.isEmpty ? "$standing" : d.position,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                  color: index == 0
                                      ? const Color(0xFFE10600)
                                      : Colors.white30,
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // ── RED ACCENT BAR ──
                            Container(
                              width: 3,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE10600),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // ── DRIVER IMAGE ──
                            ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: driverImageUrl != null
                                  ? CachedNetworkImage(
                                imageUrl: driverImageUrl,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error){
                                  return _driverFallback();
                                }
                              )
                                  : _driverFallback(),
                            ),

                            const SizedBox(width: 12),

                            // ── DRIVER INFO ──
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${d.givenName} ${d.familyName}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        d.code,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                          color: const Color(0xFFE10600),
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          d.constructorName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                            color: Colors.white38,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            // ── POINTS + WINS ──
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "${d.points} PTS",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${d.wins} WINS",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                    color: Colors.white38,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
                    : constructorAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE10600)),
                  ),
                  error: (err, stack) => Center(
                    child: Text(
                      "Error loading constructor standings",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  data: (constructors) => constructors.isEmpty?  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:[
                        Icon(
                            Icons.error_outline_rounded,
                            blendMode: BlendMode.lighten,
                            size: 100,
                            color: Colors.red.withValues(alpha: 0.5),
                        ),
                        Text(
                        "STANDINGS NOT AVAILABLE\nFOR THIS SEASON",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                          letterSpacing: 1.5,
                        ),
                      ),],
                    ),
                  ) :ListView.separated(
                    itemCount: constructors.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final c = constructors[index];
                      final constructorImageUrl =
                      TeamAssets.getConstructorImage(c.constructor.constructorId);

                      return _FrostedCard(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                            // ── POSITION ──
                            SizedBox(
                              width: 28,
                              child: Text(
                                c.position,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                  color: index == 0
                                      ? const Color(0xFFE10600)
                                      : Colors.white30,
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // ── RED ACCENT BAR ──
                            Container(
                              width: 3,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE10600),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // ── CONSTRUCTOR LOGO ──
                            Container(
                              width: 48,
                              height: 48,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.08),
                                ),
                              ),
                              child: constructorImageUrl != null
                                  ? Image.network(
                                constructorImageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) =>
                                    _constructorFallback(),
                              )
                                  : _constructorFallback(),
                            ),

                            const SizedBox(width: 12),

                            // ── CONSTRUCTOR INFO ──
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.constructor.constructorName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    c.constructor.nationality,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                      color: Colors.white38,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            // ── POINTS + WINS ──
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "${c.points} PTS",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${c.wins} WINS",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                    color: Colors.white38,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
      ],
      ),
    );
  }

  Widget _driverFallback() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Icon(Icons.person, color: Colors.white38, size: 24),
    );
  }

  Widget _constructorFallback() {
    return const Icon(Icons.shield_outlined, color: Colors.white38, size: 24);
  }

  Widget _tabButton(String label, int index) {
    final isActive = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFE10600).withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isActive
                ? Border.all(color: const Color(0xFFE10600).withValues(alpha: 0.3))
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? const Color(0xFFE10600) : Colors.white38,
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

// ── REUSABLE FROSTED GLASS CARD ──
class _FrostedCard extends StatelessWidget {
  final Widget child;

  const _FrostedCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          // in child it gets all the data we pass to the Frosted Card as child it wraps it into the frosted card and givee us the container
          child: child,
        ),
      ),
    );
  }
}