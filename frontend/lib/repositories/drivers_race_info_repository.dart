import 'dart:convert';
import 'package:http/http.dart' as http;

class DriversRaceInfo {
  const DriversRaceInfo();

  Future<List<Map<String, dynamic>>> getDriversRaceInfo() async {
    List<Map<String, dynamic>> drivers = [];

    try {
      final url = Uri.parse('http://192.168.18.12:8000/info');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final data = responseBody['drivers'];

        for (var item in data) {
          drivers.add(Map<String, dynamic>.from(item));
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching drivers info: $e');
    }

    return drivers;
  }
}