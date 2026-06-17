class DriverStanding {
  final String driverId;
  final String driverCode;
  final String position;
  final String points;
  final String wins;
  final String givenName;
  final String familyName;
  final String code;
  final String nationality;
  final String constructorName;

  DriverStanding({
    required this.driverId,
    required this.position,
    required this.driverCode,
    required this.points,
    required this.wins,
    required this.givenName,
    required this.familyName,
    required this.code,
    required this.nationality,
    required this.constructorName,
  });

  factory DriverStanding.fromJson(Map<String, dynamic> json) {
    return DriverStanding(
      driverId: json['Driver']['driverId'] ?? '',
      position: json['position'] ?? '',
      driverCode: json['Driver']['code'] ?? '' ,
      points: json['points'] ?? '',
      wins: json['wins'] ?? '',
      givenName: json['Driver']['givenName'],
      familyName: json['Driver']['familyName'],
      code: json['Driver']['code'] ?? '',
      nationality: json['Driver']['nationality'],
      constructorName: json['Constructors'][0]['name'],
    );
  }
}