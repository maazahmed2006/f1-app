import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:f1_app/models/Circut_model.dart';
import 'package:http/http.dart' as http;

class CircuitModelRepository {

  Future<CircuitModel> getCircutModel() async {
    final url = Uri.parse('http://192.168.18.12:8080/circuit');

    try {
      final response = await http.get(url).timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return CircuitModel.fromJson(responseBody);
      } else {
        final error = jsonDecode(response.body);
        throw Exception("Server error ${response.statusCode}: ${error['detail']}");
      }
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