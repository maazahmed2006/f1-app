import 'constructors_model.dart';

class ConstructorStanding {
  final String position;
  final String points;
  final String wins;
  final Constructor constructor;

  ConstructorStanding({
    required this.position,
    required this.points,
    required this.wins,
    required this.constructor,
  });

  factory ConstructorStanding.fromJson(Map<String, dynamic> json) {
    return ConstructorStanding(
      position: json['position'] ?? '',
      points: json['points'] ?? '',
      wins: json['wins'] ?? '',
      constructor: Constructor.fromJson(json['Constructor']),
    );
  }
}