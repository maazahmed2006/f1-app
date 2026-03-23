import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/constructorStanding.dart';
import '../models/constructors_model.dart';

class ConstructorRepository {

  Future <List<Constructor>> getConstructorDetails () async {
    final url = Uri.parse("https://api.jolpi.ca/ergast/f1/2026/constructors.json");
    try{
      final response = await http.get(url).timeout(Duration(seconds: 5));
      if(response.statusCode != 200){
        throw Exception("Server Error!");
      }
      final responseBody = jsonDecode(response.body);
      final data = responseBody['MRData']['ConstructorTable']['Constructors'];
      final List<Constructor> results = [];
      for (var item in data){
        results.add(Constructor.fromJson(item));
      }
      return results;
    }
    on SocketException{
      throw Exception("Oops! No Internet");
    }
  }
}

class ConstructorStandingsRepository {
  Future <List<ConstructorStanding>> getConstructorStanding (String year) async {
    final url = Uri.parse("https://api.jolpi.ca/ergast/f1/$year/constructorStandings.json");
    try{
      final response = await http.get(url).timeout(Duration(seconds: 5));
      if(response.statusCode !=200){
        throw Exception('Server Error');
      }
      final responseBody = jsonDecode(response.body);
      // DriverStandingsRepository
      // ConstructorStandingsRepository
      final standingsLists = responseBody['MRData']['StandingsTable']['StandingsLists'];
      if (standingsLists.isEmpty) return []; // ← return empty list instead of crashing
      final data = standingsLists[0]['ConstructorStandings'];
      final List<ConstructorStanding> results = [];
      for(var item in data){
        results.add(ConstructorStanding.fromJson(item));
      }
      return results;
    }
    on SocketException {
      throw Exception("Oops! NO Internet");
    }

  }
}
