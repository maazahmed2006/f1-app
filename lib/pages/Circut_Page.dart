import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:f1_app/repositories/Driver_telemetry_repository.dart';
import 'package:flutter/material.dart';

import '../models/Drivers_telemetry_model.dart';
import '../repositories/CircutRepository.dart';

class CircuitPainter extends CustomPainter {
  final List<Offset> coordinates;
  CircuitPainter({required this.coordinates});

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
    bool shouldRotate = dataWidth > dataHeight;

    if (shouldRotate) {
      canvas.translate(size.width / 2, size.height / 2);
      canvas.rotate(pi / 2);
      canvas.translate(-size.height / 2, -size.width / 2);
      double temp = dataWidth;
      dataWidth = dataHeight;
      dataHeight = temp;
    }

    double scale = min(size.width / dataWidth, size.height / dataHeight);
    double offsetX = (size.width - dataWidth * scale) / 2;
    double offsetY = (size.height - dataHeight * scale) / 2;

    Offset normalize(Offset p) => Offset(
      (p.dx - minX) * scale + offsetX,
      (p.dy - minY) * scale + offsetY,
    );

    final path = Path();
    path.moveTo(normalize(coordinates.first).dx, normalize(coordinates.first).dy);

    for (int i = 0; i < coordinates.length - 1; i++) {
      final current = normalize(coordinates[i]);
      final next = normalize(coordinates[i + 1]);
      final midX = (current.dx + next.dx) / 2;
      final midY = (current.dy + next.dy) / 2;
      path.quadraticBezierTo(current.dx, current.dy, midX, midY);
    }
    path.close();

    canvas.drawPath(path, Paint()
      ..color = Colors.blueGrey.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 26
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    canvas.drawPath(path, Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);

    canvas.drawPath(path, Paint()
      ..color = const Color(0xFF2C2C2C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);

    canvas.drawPath(path, Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);
  }

  @override
  bool shouldRepaint(CircuitPainter oldDelegate) =>
      oldDelegate.coordinates != coordinates;
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
    bool shouldRotate = dataWidth > dataHeight;

    if (shouldRotate) {
      canvas.translate(size.width / 2, size.height / 2);
      canvas.rotate(pi / 2);
      canvas.translate(-size.height / 2, -size.width / 2);
      double temp = dataWidth;
      dataWidth = dataHeight;
      dataHeight = temp;
    }

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

      final double exactIndex =
          driverState.animationController.value * (driver.points.length - 1);
      final int i = exactIndex.toInt().clamp(0, driver.points.length - 2);
      final double t = exactIndex - i;

      final Offset p1 = driver.points[i];
      final Offset p2 = driver.points[i + 1];
      final Offset interpolated = Offset(
        p1.dx + (p2.dx - p1.dx) * t,
        p1.dy + (p2.dy - p1.dy) * t,
      );

      final pos = normalize(interpolated);
      final color = Color(int.parse(driver.color.replaceAll('#', '0xFF')));

      canvas.drawCircle(pos, 9, Paint()
        ..color = color.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
      canvas.drawCircle(pos, 9, Paint()..color = color);

      final textSpan = TextSpan(
        text: driver.driverName, // abbreviation
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

  @override
  bool shouldRepaint(DriverPainter oldDelegate) => true;
}

class DriverState {
  DriverTelemetry currentTelemetry;
  int currentLap;
  final Map<String, List<DriverTelemetry>> allData;
  final Future<void> Function() loadBatch;
  late AnimationController animationController;

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
      duration: Duration(milliseconds: (currentTelemetry.lapDuration * 1000).toInt()),
    );
    animationController.addListener(onTick);
    animationController.addStatusListener(_onLapFinish);
    animationController.forward();
  }

  void _onLapFinish(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    startIndividualLap();
  }

  bool advanceLap() {
    currentLap++;
    final lapData = allData[currentLap.toString()];
    if (lapData == null) return false;
    for (int i = 0; i < lapData.length; i++) {
      if (currentTelemetry.driverNumber == lapData[i].driverNumber) {
        currentTelemetry = lapData[i];
        break;
      }
    }
    return true;
  }

  void startIndividualLap() {
    if (advanceLap()) {
      animationController.duration =
          Duration(milliseconds: (currentTelemetry.lapDuration * 1000).toInt());
      animationController.forward(from: 0.0);
    }
    loadBatch();
  }

  void dispose() {
    animationController.dispose();
  }
}

class RacePage extends StatefulWidget {
  const RacePage({super.key});

  @override
  State<RacePage> createState() => _RacePageState();
}

class _RacePageState extends State<RacePage> with TickerProviderStateMixin {
  List<Offset> coordinates = [];
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
        .map((telemetry) => DriverState(
      currentTelemetry: telemetry,
      currentLap: 1,
      vsync: this,
      allData: allData,
      loadBatch: _loadBatch,
      onTick: () => setState(() {}),
    ))
        .toList();
  }

  Future<void> _loadBatch() async {
    if (_batchLoading) return;
    _batchLoading = true;
    final batch = await DriverTelemetryRepository()
        .getTelemetry(startLap: startLap, endLap: endLap);
    allData.addAll(batch);
    startLap = endLap + 1;
    endLap = endLap + 3;
    _batchLoading = false;
  }

  Future<void> _loadCircuit() async {
    coordinates = await CircuitModelRepository().getCircutModel();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final List<DriverState> leaderboard = [...drivers]..sort((a, b) {
      if (b.currentLap != a.currentLap) {
        return b.currentLap.compareTo(a.currentLap);
      }
      return b.animationController.value
          .compareTo(a.animationController.value);
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'LAP $currentLap',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              Stack(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: CustomPaint(
                      painter: CircuitPainter(coordinates: coordinates),
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

        ],
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