import 'package:f1_app/pages/drivers_search.dart';
import 'package:f1_app/pages/home_page.dart';
import 'package:f1_app/pages/schedule.dart';
import 'package:f1_app/pages/standings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';


class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    ScheduleScreen(),
    StandingsScreen(),
    DriverSearchPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body:Stack(
          children: [
            Column(
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "PIT STOP",
                          style: GoogleFonts.orbitron(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(child: _screens[_currentIndex]),
              ],
            ),
          ],
        ),


      // ── BOTTOM NAV ──
      bottomNavigationBar: ClipRRect(

            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _navItem(Icons.home_outlined, "HOME", 0),
                    _navItem(Icons.flag_outlined, "RACES", 1),
                    _navItem(Icons.emoji_events_outlined, "STANDINGS", 2),
                    _navItem(Icons.search_outlined, "SEARCH", 3),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.translucent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFE10600).withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border.all(color: const Color(0xFFE10600).withValues(alpha: 0.3))
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFFE10600) : Colors.white38,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.orbitron(
                fontSize: 8,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? const Color(0xFFE10600) : Colors.white38,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}