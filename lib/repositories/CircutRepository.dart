
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:f1_app/models/Circut_model.dart';
import 'package:http/http.dart' as http;

class CircuitModelRepository {

  Future <List<Offset>> getCircutModel() async {
    final url = Uri.parse('YOUR-BACKEND-URL);
    final List<CircuitModel> results = [];

    try {
      final response = await http.get(url).timeout(Duration(seconds: 10));
      if (response.statusCode == 200){
        final responseBody = jsonDecode(response.body);
        final data = responseBody;

        for (var item in data) {
          results.add(CircuitModel.fromJson(item));
        }
      }

      else {
        final error = jsonDecode(response.body);
        throw Exception("Server error ${response.statusCode}: ${error['detail']}");
      }

      final List<Offset> Points = results.map((p) => Offset(p.xPosition, p.yPosition) ).toList() ;
      return Points;

    }
    on TimeoutException {
      throw Exception("Server timed out");
    }
    on SocketException {
      throw Exception("Oops! No Internet");
    }
    catch (e) {
      throw Exception(e);
    }
  }
}
