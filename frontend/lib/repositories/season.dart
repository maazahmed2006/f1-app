import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/season_model.dart';

class SeasonRepository {

  Future <List<Season>> getSeasonDetails (String year) async {
    final url = Uri.parse("https://api.jolpi.ca/ergast/f1/$year.json");
    try{
      final response = await http.get(url).timeout(Duration(seconds: 5));
      if(response.statusCode != 200){
        throw Exception("Server Error!");
      }
      final responseBody = jsonDecode(response.body);
      final data = responseBody['MRData']['RaceTable']['Races'];
      final List<Season> results = [];
      for (var item in data){
        results.add(Season.fromJson(item));
      }
      return results;
    }
    on SocketException{
      throw Exception("Oops! No Internet");
    }
    }
  }
