import 'dart:ui';

class DriverTelemetry {

  final String driverName;
  final String color;
  final int driverNumber;
  final int gridPosition ;
  final double lapStartTime;
  final double lapDuration;
  List <Offset> points = [] ;


  DriverTelemetry({
    required this.driverName ,
    required this.color ,
    required this.driverNumber ,
    required this.gridPosition ,
    required this.lapStartTime ,
    required this.lapDuration ,
    required this.points ,
});


  factory DriverTelemetry.fromJson(Map<String , dynamic> json) {
      return DriverTelemetry(
          driverName: json['driver'],
          color: json['color'],
          driverNumber: json['driverNumber'],
          gridPosition: json['gridPosition'],
          lapStartTime: json['lapStartTime'],
          lapDuration: json['lapDuration'] ,
          points : (json['points'] as List ).map((points) => Offset(points['X'] as double, points['Y'] as double)).toList(),
      );
  }
}