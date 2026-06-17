class Season {
  final String raceName;
  final String round;
  final String date;
  final String circuitName;
  final String country;
  final String? time;

  Season({
    required this.raceName,
    required this.round,
    required this.date,
    required this.circuitName,
    required this.country,
    this.time
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      raceName: json['raceName'] ?? '',
      round: json['round'] ?? '',
      date: json['date'] ?? '',
      circuitName: json['Circuit']['circuitName'] ?? '',
      country: json['Circuit']['Location']['country'] ?? '',
      time: json['time'] ?? '',
    );
  }
}