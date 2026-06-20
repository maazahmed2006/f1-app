import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:f1_app/repositories/Driver_telemetry_repository.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/Drivers_telemetry_model.dart';
import '../repositories/CircutRepository.dart';

class CircuitPainter extends CustomPainter {
  final List<Offset> coordinates;
  final List<Offset> pitLaneCoordinates;

  CircuitPainter({required this.coordinates, required this.pitLaneCoordinates});


  @override
  void paint(Canvas canvas, Size size) {
    if (coordinates.isEmpty) return;

    double maxX = coordinates.first.dx;
    double minX = coordinates.first.dx;
    double maxY = coordinates.first.dy;
    double minY = coordinates.first.dy;

    for (final p in coordinates) {
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }

    double dataWidth = maxX - minX;
    double dataHeight = maxY - minY;

    double scale = min(size.width / dataWidth, size.height / dataHeight);
    double offsetX = (size.width - dataWidth * scale) / 2;
    double offsetY = (size.height - dataHeight * scale) / 2;

    Offset normalize(Offset p) =>
        Offset(
          (p.dx - minX) * scale + offsetX,
          (p.dy - minY) * scale + offsetY,
        );


    final path = Path();
    path.moveTo(
      normalize(coordinates.first).dx,
      normalize(coordinates.first).dy,
    );

    for (int i = 0; i < coordinates.length - 1; i++) {
      final current = normalize(coordinates[i]);
      final next = normalize(coordinates[i + 1]);
      final midX = (current.dx + next.dx) / 2;
      final midY = (current.dy + next.dy) / 2;
      path.quadraticBezierTo(current.dx, current.dy, midX, midY);
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.blueGrey.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.grey.shade700
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0x9E2C2C2C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    if (pitLaneCoordinates.isNotEmpty) {
      final pitPath = Path();
      pitPath.moveTo(
        normalize(pitLaneCoordinates.first).dx,
        normalize(pitLaneCoordinates.first).dy,
      );
      for (final p in pitLaneCoordinates.skip(1)) {
        final n = normalize(p);
        pitPath.lineTo(n.dx, n.dy);
      }

      // Offset last = coordinates.last ;
      // final lastNormalized = normalize(last) ;
      // path.lineTo(lastNormalized.dx, lastNormalized.dy) ;
      // Outer glow
      canvas.drawPath(
        pitPath,
        Paint()
          ..color = Colors.purple.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );

      // Core line
      canvas.drawPath(
        pitPath,
        Paint()
          ..color = Colors.purple
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

      // Bright center
      canvas.drawPath(
        pitPath,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }


  @override
  bool shouldRepaint(CircuitPainter oldDelegate) =>
      oldDelegate.coordinates != coordinates ||
          oldDelegate.pitLaneCoordinates != pitLaneCoordinates;
}




class DriverPainter extends CustomPainter {
  final List<Offset> circuitPoints;
  final List<DriverState> drivers;

  DriverPainter({required this.circuitPoints, required this.drivers});

  @override
  void paint(Canvas canvas, Size size) {
    if (circuitPoints.isEmpty || drivers.isEmpty) return;

    double minX = circuitPoints.first.dx;
    double maxX = circuitPoints.first.dx;
    double minY = circuitPoints.first.dy;
    double maxY = circuitPoints.first.dy;

    for (final p in circuitPoints) {
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }

    double dataWidth = maxX - minX;
    double dataHeight = maxY - minY;

    double scale = min(size.width / dataWidth, size.height / dataHeight);
    double offsetX = (size.width - dataWidth * scale) / 2;
    double offsetY = (size.height - dataHeight * scale) / 2;

    Offset normalize(Offset p) => Offset(
      (p.dx - minX) * scale + offsetX,
      (p.dy - minY) * scale + offsetY,
    );

    for (final driverState in drivers) {
      final driver = driverState.currentTelemetry;
      if (driver.points.isEmpty) continue;
      if(driver.lapStartTime + driver.lapDuration == 0) continue ;

      final double exactIndex =
          driverState.animationController.value * (driver.points.length - 1);
      final int i = exactIndex.toInt().clamp(0, driver.points.length - 2);
      final double t = exactIndex - i;


      if(driver.points[i] ==  null && driver.points[i+1] == null){
          driverState.animationController.stop();
          continue ;
      }
      else
        {
          final Offset p1 = driver.points[i]!;
          final Offset p2 = driver.points[i + 1]!;
          final Offset interpolated = Offset(
            p1.dx + (p2.dx - p1.dx) * t,
            p1.dy + (p2.dy - p1.dy) * t,
          );

          final pos = normalize(interpolated);
          final color = Color(int.parse(driver.color.replaceAll('#', '0xFF')));

          final bool inPits = driverState.activePitIn != null && driverState.activePitOut != null
              ? driverState.pitAnimationController.value >=
              (driverState.activePitIn! / (driverState.activePitOut ?? driver.lapDuration)) &&
              driverState.pitAnimationController.value <=
                  (driverState.activePitOut! / (driverState.activePitOut ?? driver.lapDuration))
              : false;

          canvas.drawCircle(
            pos,
            inPits ? 7 : 9,
            Paint()
              ..color = color.withValues(alpha: 0.3)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
          );
          canvas.drawCircle(pos, inPits ? 7 : 9, Paint()..color = color);

          final textSpan = TextSpan(
            text: inPits ? '${driver.driverName}\nIN PIT' : driver.driverName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 7,
              fontWeight: FontWeight.bold,
            ),
          );

          final textPainter = TextPainter(
            text: textSpan,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          );

          textPainter.layout();

          final offset = Offset(
            pos.dx - textPainter.width / 2,
            pos.dy - textPainter.height / 2,
          );

          textPainter.paint(canvas, offset);
        }
    }

  }


  @override
  bool shouldRepaint(DriverPainter oldDelegate) => true;
}

class DriverState {
  DriverTelemetry currentTelemetry;
  int currentLap;
  final Map<String, List<DriverTelemetry>> allData;
  final Future<void> Function() loadBatch;
  late AnimationController animationController;
  late AnimationController pitAnimationController;
  int currentIndex = 0;

  double? activePitIn;
  double? activePitOut;

  DriverState({
    required this.currentTelemetry,
    required this.currentLap,
    required this.allData,
    required this.loadBatch,
    required TickerProvider vsync,
    required VoidCallback onTick,
  }) {
    animationController = AnimationController(
      vsync: vsync,
      duration: Duration(
        milliseconds: (currentTelemetry.lapDuration * 1000).toInt(),
      ),
    );
    animationController.addListener(() {
      updateIndex();
      onTick();
    });
    animationController.addStatusListener(_onLapFinish);
    animationController.forward();

    if (currentTelemetry.pitInTime != null && currentTelemetry.pitOutTime != null) {
      activePitIn = currentTelemetry.pitInTime;
      activePitOut = currentTelemetry.pitOutTime;
    }

    pitAnimationController = AnimationController(
      vsync: vsync,
      duration: Duration(
        milliseconds: ((activePitOut ?? currentTelemetry.lapDuration) * 1000).toInt(),
      ),
    );

    pitAnimationController.addListener(onTick);
    pitAnimationController.forward();
    pitAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        activePitIn = null;
        activePitOut = null;
        _resetPitController();
      }
    });
  }

  void _resetPitController() {
    activePitIn = currentTelemetry.pitInTime;
    activePitOut = currentTelemetry.pitOutTime;

    pitAnimationController.reset();
    pitAnimationController.duration = Duration(
      milliseconds: ((activePitOut ?? currentTelemetry.lapDuration) * 1000).toInt(),
    );
    pitAnimationController.forward();
  }

  void updateIndex() {
    final points = currentTelemetry.points;
    if (points.isEmpty) return;

    currentIndex = (animationController.value * (points.length - 1)).toInt();
  }

  void _onLapFinish(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    startIndividualLap();
  }

  bool advanceLap() {
    currentLap++;
    final lapData = allData[currentLap.toString()];
    if (lapData == null)
      return false;
    else {
      for (int i = 0; i < lapData.length; i++) {
        if (currentTelemetry.driverNumber == lapData[i].driverNumber) {
          currentTelemetry = lapData[i];
        }
      }
      return true ;
    }
  }

  void startIndividualLap() {
    if (advanceLap()) {
      animationController.duration = Duration(
        milliseconds: (currentTelemetry.lapDuration * 1000).toInt(),
      );
      animationController.forward(from: 0.0);
    }

    else {
      animationController.stop();
    }
    loadBatch();
  }

  double raceProgress() {
    return currentLap + animationController.value;
  }

  void dispose() {
    animationController.dispose();
    pitAnimationController.dispose();
  }
}

class RacePage extends StatefulWidget {
  const RacePage({super.key});

  @override
  State<RacePage> createState() => _RacePageState();
}

class _RacePageState extends State<RacePage> with TickerProviderStateMixin {
  List<Offset> coordinates = [];
  List<Offset> pitLaneCoordinates = [];


  bool loading = true;
  Map<String, List<DriverTelemetry>> allData = {};
  List<DriverState> drivers = [];
  int startLap = 1;
  int endLap = 3;
  bool _batchLoading = false;

  int get currentLap =>
      drivers.isEmpty ? 1 : drivers.map((d) => d.currentLap).reduce(max);

  @override
  void initState() {
    super.initState();
    loadRace();
  }

  Future<void> loadRace() async {
    await Future.wait([_loadBatch(), _loadCircuit()]);
    _initDrivers();
    setState(() => loading = false);
  }

  void _initDrivers() {
    final firstLap = allData["1"];
    if (firstLap == null) return;

    drivers = firstLap
        .map(
          (telemetry) => DriverState(
        currentTelemetry: telemetry,
        currentLap: 1,
        vsync: this,
        allData: allData,
        loadBatch: _loadBatch,
        onTick: () => setState(() {}),
      ),
    )
        .toList();
  }

  Future<void> _loadBatch() async {
    if (_batchLoading) return;
    _batchLoading = true;
    final batch = await DriverTelemetryRepository().getTelemetry(
      startLap: startLap,
      endLap: endLap,
    );
    allData.addAll(batch);
    startLap = endLap + 1;
    endLap = endLap + 3;
    _batchLoading = false;
  }

  Future<void> _loadCircuit() async {
    final model = await CircuitModelRepository().getCircutModel();
    coordinates = model.circuit;
    pitLaneCoordinates = model.pitLane;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      endDrawerEnableOpenDragGesture: true,
      endDrawer: _buildLeaderboardDrawer(),
      body: loading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Preparing Race Telemetry..",
              style: GoogleFonts.orbitron(
                fontSize: 15,
                fontWeight: FontWeight.w300,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: LinearProgressIndicator(color: Colors.red),
            ),
          ],
        ),
      )
          : SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 10),
                  child: Text(
                    'LAP $currentLap',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16, top: 10),
                  child: Builder(
                    builder: (context) {
                      return GestureDetector(
                        onTap: () {
                          Scaffold.of(context).openEndDrawer();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Icon(
                            Icons.leaderboard,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Stack(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: CustomPaint(
                    painter: CircuitPainter(
                      coordinates: coordinates,
                      pitLaneCoordinates: pitLaneCoordinates,  // add this
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: CustomPaint(
                    painter: DriverPainter(
                      circuitPoints: coordinates,
                      drivers: drivers,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardDrawer() {
    final sorted = [...drivers];
    sorted.sort((a, b) => b.raceProgress().compareTo(a.raceProgress()));

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        margin: const EdgeInsets.only(left: 60),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: Column(
              children: [
                const SizedBox(height: 60),
                const Text(
                  'LEADERBOARD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: sorted.length,
                    itemBuilder: (context, index) {
                      final d = sorted[index];
                      final telemetry = d.currentTelemetry;
                      final color = Color(
                        int.parse(telemetry.color.replaceAll('#', '0xFF')),
                      );

                      final int safeIndex = d.currentIndex.clamp(
                        0,
                        telemetry.speeds.isEmpty ? 0 : telemetry.speeds.length - 1,
                      );
                      final double? currentSpeed =
                      telemetry.speeds.isEmpty ? null : telemetry.speeds[safeIndex];

                      final compound = telemetry.compound ?? '?';
                      final tyreLife = telemetry.tyreLife;

                      final Color compoundColor = switch (compound.toUpperCase()) {
                        'SOFT'   => const Color(0xFFE8002D),
                        'MEDIUM' => const Color(0xFFFFD514),
                        'HARD'   => Colors.white,
                        'INTER'  => const Color(0xFF39B54A),
                        'WET'    => const Color(0xFF0067FF),
                        _        => Colors.grey,
                      };

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 3,
                              height: 36,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    telemetry.driverName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (currentSpeed != null)
                                    Text(
                                      '${currentSpeed.toInt()} km/h',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.5),
                                        fontSize: 10,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: compoundColor.withValues(alpha: 0.15),
                                border: Border.all(color: compoundColor, width: 1.5),
                              ),
                              child: Center(
                                child: Text(
                                  compound.isEmpty ? '?' : compound[0].toUpperCase(),
                                  style: TextStyle(
                                    color: compoundColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'L${d.currentLap}',
                                    style: TextStyle(color: color, fontSize: 10),
                                  ),
                                ),
                                if (tyreLife != null)
                                  Text(
                                    '${tyreLife}L old',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.4),
                                      fontSize: 9,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    for (final driver in drivers) {
      driver.dispose();
    }
    super.dispose();
  }
}