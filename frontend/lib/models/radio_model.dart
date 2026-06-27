class RadioData {
  final int? lapNo;
  final List<double> time;
  final List<String> catgeory;
  final List<String> message;
  final List<int?> corner;

  RadioData({
    required this.lapNo,
    required this.time,
    required this.catgeory,
    required this.message,
    required this.corner,
  });

  factory RadioData.fromJson(Map<String, dynamic> json) {
    return RadioData(
      lapNo: json['LapNo'],
      time: (json['Time'] as List)
          .map((p) => (p as num).toDouble())
          .toList(),
      catgeory: (json['Category'] as List)
          .map((p) => p.toString())
          .toList(),
      message: (json['Message'] as List)
          .map((m) => m.toString())
          .toList(),
      corner: (json['Corner'] as List)
          .map<int?>((c) => c as int?)
          .toList(),
    );
  }
}