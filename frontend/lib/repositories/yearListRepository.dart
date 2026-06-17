import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/yearslist_model.dart';

class YearListRepository {
  Future<List<YearList>> getYearListDetails() async {
    int limit = 30;
    int offset = 0;
    int total = 1 ;
    List <YearList> results = [];
    while (offset < total) {
      final url = Uri.parse('https://api.jolpi.ca/ergast/f1/seasons.json?limit=$limit&offset=$offset');
      try {
        final response = await http.get(url).timeout(const Duration(seconds: 5));

        if (response.statusCode != 200) {
          throw Exception("Server Error");
        }

        final responseBody = jsonDecode(response.body);
        total = int.parse(responseBody['MRData']['total']);
        final List seasonsList =
        responseBody['MRData']['SeasonTable']['Seasons'];
        offset+= limit;
        for (var item in seasonsList){
          results.add(YearList.fromJson(item));
        }
      }
      on SocketException {
        throw Exception("No Internet Connection");
      }
    }
    return results;
  }
}