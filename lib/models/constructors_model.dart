class Constructor {
  final String constructorId;
  final String constructorName;
  final String nationality;

  Constructor({
    required this.constructorId,
    required this.constructorName,
    required this.nationality,
  });

  factory Constructor.fromJson(Map<String, dynamic> json) {
    return Constructor(
      constructorId: json['constructorId'] ?? '',
      constructorName: json['name'] ?? '',
      nationality: json['nationality'] ?? '',
    );
  }
}