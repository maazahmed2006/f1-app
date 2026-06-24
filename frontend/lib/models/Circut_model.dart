import 'dart:ui';

class CircuitModel {
  final List<Offset> circuit;
  final List<Offset>? pitLane;
  final List<Map<String, dynamic>> cornerData;

  CircuitModel({
    required this.circuit,
    required this.pitLane,
    required this.cornerData,
  });

  factory CircuitModel.fromJson(Map<String, dynamic> json) {
    return CircuitModel(
      circuit: (json['circuit'] as List)
          .map((p) => Offset((p['X'] as num).toDouble(), (p['Y'] as num).toDouble()))
          .toList(),
      pitLane: json['pitLane'] != null
          ? (json['pitLane'] as List)
          .map((p) => Offset((p['X'] as num).toDouble(), (p['Y'] as num).toDouble()))
          .toList()
          : null,
      cornerData: json['cornerData'] != null
          ? (json['cornerData'] as List).map((m) {
        return {
          'cornerNumber': m['cornerNumber'],
          'X':            (m['coordinates']['X'] as num).toDouble(),
          'Y':            (m['coordinates']['Y'] as num).toDouble(),
          'angle':        (m['angle'] as num).toDouble(),
          'distance':     (m['distance'] as num).toDouble(),
        };
      }).toList()
          : [],
    );
  }
}