import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:f1_app/pages/Circut_Page.dart';
import 'package:f1_app/repositories/drivers_race_info_repository.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/team_assets.dart';


class DriverCardsAnimation extends StatefulWidget {
  const DriverCardsAnimation({super.key});

  @override
  State<DriverCardsAnimation> createState() => _DriverCardsAnimationState();
}

class _DriverCardsAnimationState extends State<DriverCardsAnimation> {
  List<Map<String, dynamic>> driversInfo = [];
  bool loading = true;

  Timer? timer;
  int currentIndex = 0;

  final int batchSize = 3;

  @override
  void initState() {
    super.initState();
    getDriversDetails();
    RacePage();
  }

  Future<void> getDriversDetails() async {
    try {
      driversInfo = await DriversRaceInfo().getDriversRaceInfo();

      setState(() {
        loading = false;
      });

      startAnimation();

    } catch (e) {
      print("UI Error: $e");
    }
  }

  void startAnimation() {
    timer = Timer.periodic(Duration(seconds: 5), (t) {
      if (currentIndex + batchSize >= driversInfo.length) {
        t.cancel();
        return;
      }

      setState(() {
        currentIndex += batchSize;
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TweenAnimationBuilder(
                    duration: Duration(seconds: 3),
                    tween: Tween<double>(begin: -100, end: 0),
                    curve: Curves.easeOutCubic,

                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(value, 0), // 👉 right → left
                        child: Opacity(
                          opacity: (1 - (value / 100)).clamp(0, 1.0),
                          child: child,
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Starting Grid" ,
                        style: GoogleFonts.orbitron(
                          fontSize: 30,
                          fontWeight: FontWeight.w900 ,
                          letterSpacing: 2
                        ),
                      ),
                    ),
                ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => RacePage(),
                      ),
                      );
                    },
                      icon: Icon(
                          Icons.arrow_circle_right,
                          color: Colors.blue,
                          size: 40,
                      ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(

                    itemCount: batchSize,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.78,
                    ),
                    itemBuilder: (context, index) {
                      final driverIndex = index + currentIndex;
                      if (driverIndex >= driversInfo.length) {
                        return const SizedBox.shrink();
                      }

                      return TweenAnimationBuilder<double>(
                        key: ValueKey(driverIndex),
                        duration: Duration(seconds: 2),
                        tween: Tween<double>(begin: 100, end: 0),
                        curve: Curves.easeOutCubic,

                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(value, 0), // 👉 right → left
                            child: Opacity(
                              opacity: (1 - (value / 100)).clamp(0.0, 1.0),
                              child: child,
                            ),
                          );
                        },

                        child: DriverCard(
                          code: driversInfo[driverIndex]['abbreviation'] ?? 'N/A',
                          driverName: driversInfo[driverIndex]['driverName'] ?? 'Unknown',
                          gridPosition: driversInfo[driverIndex]['gridPosition'] ?? 0,
                          driverNumber: driversInfo[driverIndex]['driverNumber'] ?? 0,
                          teamColor: driversInfo[driverIndex]['teamColor'] ?? '#FF0000',
                        ),
                      );
                    }
                ),
              ),
            ],
          )
      ),
    );
  }
}

class DriverCard extends StatelessWidget {
  final String code;
  final String driverName;
  final int gridPosition;
  final int driverNumber;
  final String teamColor;

  const DriverCard({
    super.key,
    required this.code,
    required this.driverName,
    required this.gridPosition,
    required this.driverNumber,
    required this.teamColor,
  });

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xff')));
    } catch (e) {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = TeamAssets.getDriverImage(code);
    final themeColor = _parseColor(teamColor);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: themeColor.withOpacity(0.6),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: themeColor.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children:
          [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 70,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 10,
                ),
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  );
                },
              ),
            ),
            ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: image ?? '',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorWidget: (context, url, error) => Icon(
                      Icons.person,
                      color: themeColor.withOpacity(0.5),
                      size: 120,
                    ),
                  ),
                ),

                // 🔥 DARK OVERLAY (for readability)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.4),
                          Colors.black.withOpacity(0.9),
                        ],
                      ),
                    ),
                  ),
                ),

                // 🔥 TOP BADGES
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: themeColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'P$gridPosition',
                        style: GoogleFonts.orbitron(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: themeColor.withOpacity(0.6),
                      ),
                    ),
                    child: Text(
                      '#$driverNumber',
                      style: GoogleFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: themeColor,
                      ),
                    ),
                  ),
                ),

                // 🔥 CONTENT ON TOP
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 70),

                      const Spacer(),

                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 40,
                            decoration: BoxDecoration(
                              color: themeColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                code,
                                style: GoogleFonts.orbitron(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                driverName.toUpperCase(),
                                style: GoogleFonts.orbitron(
                                  fontSize: 12,
                                  color: Colors.grey[300],
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Container(
                        height: 3,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              themeColor,
                              themeColor.withOpacity(0.5),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
        ),
      ),
    );
  }
}