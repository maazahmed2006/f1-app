class YearList {
  final String season;

  YearList({
    required this.season,
  });

  factory YearList.fromJson(Map<String, dynamic> json) {
    return YearList(
      season: json['season'] as String,
    );
  }
}