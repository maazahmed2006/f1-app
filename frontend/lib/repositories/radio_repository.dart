import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:f1_app/models/radio_model.dart';
import 'package:http/http.dart' as http;

class RadioDataRepository {

  Future <List<RadioData>> getRadioData() async {

    final url = Uri.parse('http://192.168.18.12:8000/radio');
    final List<RadioData> radioData = [];

    try {
      final response = await http.get(url).timeout(Duration(seconds: 5));
      if(response.statusCode == 200){
        final responseData = jsonDecode(response.body);
        for(String key in responseData.keys)
          {
            radioData.add(RadioData.fromJson(responseData[key][0]));
          }
      }
      else {
        final error = jsonDecode(response.body);
        throw Exception(
            "Server Error: ${response.statusCode}: ${error['detail']}"
        );
      }

      return radioData ;
    }

    on SocketException {
      throw "Oops No Internet" ;
    }
    on TimeoutException {
      throw "Server timed out" ;
    }

    catch(e){
      rethrow ;
    }

  }
}