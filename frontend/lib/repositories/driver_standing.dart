import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/drivers_Standing.dart';

class DriverStandingsRepository {
  Future<List<DriverStanding>> getDriverStandings(String year) async {
    final url = Uri.parse(
        "https://api.jolpi.ca/ergast/f1/$year/driverStandings/");
    try {
      final response = await http.get(url);
      if (response.statusCode != 200) {
        throw Exception("Server Error");
      }
      final responseBody = jsonDecode(response.body);
      final standingsLists = responseBody['MRData']['StandingsTable']['StandingsLists'];
      if (standingsLists.isEmpty) return []; // ← return empty list instead of crashing
      final data = standingsLists[0]['DriverStandings'] as List;

      return data.map((item) => DriverStanding.fromJson(item)).toList();
    } on SocketException {
      throw Exception('Oops! No Internet');
    }
  }
}