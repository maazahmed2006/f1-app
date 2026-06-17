import 'dart:convert';

import 'package:f1_app/models/Drivers_telemetry_model.dart';
import 'package:http/http.dart' as http;

class DriverTelemetryRepository {

  Future <Map<String, List<DriverTelemetry>>> getTelemetry(
      {required int startLap , required int endLap  }) async {
<<<<<<< HEAD
    String url = 'http://YOUR-BACKEND-URL/laps/batch/${startLap}/${endLap}';
=======
    String url = 'http://192.168.18.12:8080/laps/batch/${startLap}/${endLap}';
>>>>>>> aa0ca06 (Add Starting Grid Animation with Driver Cards)

    final parsedUrl = Uri.parse(url);
    final response = await http.get(parsedUrl);

    final Map<String, List<DriverTelemetry>> results = {};


    try {
      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception("Server Error:  ${response.statusCode}: $error");
      }

      else {
        final responseBody = jsonDecode(response.body);
        final data = responseBody;
        for (int i = startLap; i <= endLap; i++) {
          results['$i'] = [for(var item in data['$i'])
            DriverTelemetry.fromJson(item)
          ];
          }
        }
      return results;
    }
    catch (e) {
      rethrow;
    }
    }

  }


