class DriverRaceResult {
  final String season;
  final String round;
  final String raceName;
  final String position;
  final String points;
  final String grid;
  final String status;

  DriverRaceResult({
    required this.season,
    required this.round,
    required this.raceName,
    required this.position,
    required this.points,
    required this.grid,
    required this.status,
  });

  factory DriverRaceResult.fromJson(Map<String, dynamic> json) {
    final result = json['Results'][0];
    return DriverRaceResult(
      season: json['season'] ?? '',
      round: json['round'] ?? '',
      raceName: json['raceName'] ?? '',
      position: result['position'] ?? 'N/A',
      points: result['points'] ?? '0',
      grid: result['grid'] ?? 'N/A',
      status: result['status'] ?? 'N/A',
    );
  }
}

class DriverCareerStats {
  final int totalRaces;
  final int wins;
  final int podiums;
  final int poles;
  final double totalPoints;
  final Map<String, double> pointsPerSeason;

  DriverCareerStats({
    required this.totalRaces,
    required this.wins,
    required this.podiums,
    required this.poles,
    required this.totalPoints,
    required this.pointsPerSeason,
  });

  factory DriverCareerStats.fromResults(List<DriverRaceResult> results) {
    int wins = 0;
    int podiums = 0;
    int poles = 0;
    double totalPoints = 0;
    Map<String, double> perSeason = {};

    for (var r in results) {
      final pos = int.tryParse(r.position) ?? 99;
      final pts = double.tryParse(r.points) ?? 0;
      final grid = int.tryParse(r.grid) ?? 99;

      if (pos == 1) wins++;
      if (pos <= 3) podiums++;
      if (grid == 1) poles++;
      totalPoints += pts;
      perSeason[r.season] = (perSeason[r.season] ?? 0) + pts;
    }

    return DriverCareerStats(
      totalRaces: results.length,
      wins: wins,
      podiums: podiums,
      poles: poles,
      totalPoints: totalPoints,
      pointsPerSeason: perSeason,
    );
  }
}