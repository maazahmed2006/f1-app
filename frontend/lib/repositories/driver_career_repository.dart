import 'dart:convert';
import 'dart:io';

import 'package:f1_app/models/drivers_career_results.dart';
import 'package:http/http.dart' as http;

class DriverCareerRepository{
  Future <DriverCareerStats> getDriverCareerResults (String driverId) async {

    int offset=0;
    final List<DriverRaceResult> results = [];

    while( true ){
      final url = Uri.parse('https://api.jolpi.ca/ergast/f1/drivers/$driverId/results/?limit=100&offset=$offset');
      try{
        final response =  await http.get(url).timeout(Duration(seconds: 5));
        if(response.statusCode!=200){
          throw Exception("An Error Occurred");
        }
        final responseBody =  jsonDecode(response.body);
        // we will use this to first get the total and then compare it with offset
        final total = int.parse(responseBody['MRData']['total']);
        final data = responseBody['MRData']['RaceTable']['Races'];
        for(var item in data){
          results.add(DriverRaceResult.fromJson(item));
        }
        offset+=100;
        if(offset >= total){
          break;
        }
      }
      on SocketException{
        throw Exception("No Network Connection");
      }
    }
    return DriverCareerStats.fromResults(results);
  }
}