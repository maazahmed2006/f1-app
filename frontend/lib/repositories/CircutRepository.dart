import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:f1_app/models/Circut_model.dart';
import 'package:http/http.dart' as http;

class CircuitModelRepository {

  Future<CircuitModel> getCircutModel() async {
    final url = Uri.parse('http://YOUR_IP_ADDRESS:YOUR_PORT/circuit');
    try {
      final response = await http.get(url).timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return CircuitModel.fromJson(responseBody);
      } else {
        final error = jsonDecode(response.body);
        throw ("Server error ${response.statusCode}: ${error['detail']}");
      }
    }
    on TimeoutException {
      throw "Server timed out" ;
    }
    on SocketException {
      throw "Oops! No Internet" ;
    }
    catch (e){
      rethrow;
    }
  }
}
