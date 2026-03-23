import 'dart:convert';
import 'dart:io';
import 'package:f1_app/models/winners_model.dart';
import 'package:http/http.dart' as http;

class WinnerRepository{
  Future <List<Result>> getWinner(String year) async {
    final url = Uri.parse("https://api.jolpi.ca/ergast/f1/$year/results/1/");
    try {
      final response = await http.get(url);
      if(response.statusCode != 200){
        throw Exception("Server Error");
      }
      final responseBody = jsonDecode(response.body);
      final data = responseBody['MRData']['RaceTable']['Races'];
      final List<Result> results = [];
      for(var item in data){
        results.add(Result.fromJson(item));
      }
      return results;
    }
    on SocketException{
      throw Exception('Oops! No Internet');
    }
  }
}