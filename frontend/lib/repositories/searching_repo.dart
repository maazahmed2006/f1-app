import 'dart:convert';

import 'package:f1_app/models/drivers_model.dart';
import 'package:http/http.dart' as http;

class DriverListRepository {
  Future<List<Drivers>> getDriversList() async {
    int limit = 100;
    int offset = 0;
    final List<Drivers> results = [];

    while (true) {
      final url = Uri.parse(
        'https://api.jolpi.ca/ergast/f1/drivers/?limit=$limit&offset=$offset',
      );
      try {
        final response = await http.get(url).timeout(Duration(seconds: 5));

        if (response.statusCode != 200) {
          throw Exception("Server Error!");
        }

        final responseBody = jsonDecode(response.body);
        final int total = int.parse(responseBody['MRData']['total'].toString());
        final List data = responseBody['MRData']['DriverTable']['Drivers'];

        for (var item in data) {
          results.add(Drivers.fromJson(item));
        }

        offset += limit;

        if (offset >= total) break; // ← exit condition

      } catch (e) {
        throw Exception("Failed to fetch drivers: $e"); // ← required to close try
      }
    }

    return results;
  }
}