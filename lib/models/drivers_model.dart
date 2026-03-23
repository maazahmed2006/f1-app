class Drivers {
final String driverId;
final String givenName;
final String familyName;
final String? dateOfBirth;
final String? nationality;

Drivers({
  required this.driverId,
  required this.givenName,
  required this.familyName,
  this.dateOfBirth,
  this.nationality,
});

factory Drivers.fromJson(Map<String, dynamic> json) {
return Drivers(
driverId:    json['driverId']    as String,
givenName:   json['givenName']   as String,
familyName:  json['familyName']  as String,
dateOfBirth: json['dateOfBirth'] as String?,
nationality: json['nationality'] as String?,
);
}
}