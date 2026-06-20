import 'dart:ui';

class CircuitModel {
  final List<Offset> circuit;
  final List<Offset> pitLane;

  CircuitModel({
    required this.circuit,
    required this.pitLane,
  });

  factory CircuitModel.fromJson(Map<String, dynamic> json) {
    return CircuitModel(
      circuit: (json['circuit'] as List)
          .map((p) => Offset((p['X'] as num).toDouble(), (p['Y'] as num).toDouble()))
          .toList(),
      pitLane: (json['pitLane'] as List)
          .map((p) => Offset((p['X'] as num).toDouble(), (p['Y'] as num).toDouble()))
          .toList(),
    );
  }
}