import 'dart:ui';

class CircuitModel {
  final List<Offset> circuit;
  final List<Offset>? pitLane;
  final List<Map<String, dynamic>> cornerData;
  final List<Map<String , double>> sector1 ;
  final List<Map<String , double>> sector2 ;
  final List<Map<String , double>> sector3 ;

  CircuitModel({
    required this.circuit,
    required this.pitLane,
    required this.cornerData,
    required this.sector1 ,
    required this.sector2 ,
    required this.sector3 ,
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

      sector1: json['sectorData'] != null ?
      (json['sectorData']['Sector1'] as List).map((s1) => {
        'X' : (s1['X'] as num).toDouble(),
        'Y' : (s1['Y'] as num).toDouble(),
      }).toList()
          : [],

      sector2: json['sectorData'] != null ?
      (json['sectorData']['Sector2'] as List).map((s2) => {
        'X' : (s2['X'] as num).toDouble(),
        'Y' : (s2['Y'] as num).toDouble(),
      }).toList()
          : [],
      sector3: json['sectorData'] != null ?
      (json['sectorData']['Sector3'] as List).map((s3) => {
        'X' : (s3['X'] as num).toDouble(),
        'Y' : (s3['Y'] as num).toDouble(),
      }).toList()
          : [],
    );
  }
}