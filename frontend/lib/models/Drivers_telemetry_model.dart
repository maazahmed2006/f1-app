import 'dart:ui';

class DriverTelemetry {

  final String driverName;
  final String color;
  final int driverNumber;
  final int gridPosition ;
  final double lapStartTime;
  final double lapDuration;
  final  pitInTime;
  final  pitOutTime;
  List <Offset?>points = [] ;


  DriverTelemetry({
    required this.driverName ,
    required this.color ,
    required this.driverNumber ,
    required this.gridPosition ,
    required this.lapStartTime ,
    required this.lapDuration ,
    required this.pitInTime ,
    required this.pitOutTime ,
    required this.points ,
});


  factory DriverTelemetry.fromJson(Map<String , dynamic> json) {
    return DriverTelemetry(
      driverName: json['driver'],
      color: json['color'],
      driverNumber: json['driverNumber'],
      gridPosition: json['gridPosition'],
      lapStartTime: (json['lapStartTime'] as num).toDouble(),
      pitInTime: json['pitInTime'],
      pitOutTime: json['pitOutTime'],
      lapDuration: (json['lapDuration'] as num).toDouble(),

      points: (json['points'] as List).map((point) {
        if (point == null || point['X'] == null || point['Y'] == null) {
          return null;
        }

        return Offset(
          (point['X'] as num).toDouble(),
          (point['Y'] as num).toDouble(),
        );
      }).toList(),
    );
  }
}