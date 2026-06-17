class Result{
  final String round;
  String givenName;
  String lastName;
  String code;
  String laps;
  String fastestLap;

  Result({
    required this.round,
    required this.givenName,
    required this.lastName,
    required this.code,
    required this.laps,
    required this.fastestLap,
});

  factory Result.fromJson (Map<String , dynamic> json) {
    return Result(
        round: json['round'],
        givenName: json['Results'][0]['Driver']['givenName'],
        lastName: json['Results'][0]['Driver']['familyName'],
        code: json['Results'][0]['Driver']['code'] ?? "N/A",
        laps: json['Results'][0]['laps'],
        fastestLap: json['Results'][0]['FastestLap']?['lap'] ?? "N/A",
    );
  }
}