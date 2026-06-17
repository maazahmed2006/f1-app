import 'package:f1_app/models/yearslist_model.dart';
import 'package:f1_app/repositories/yearListRepository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final yearListProvider = FutureProvider <List<YearList>>  ((ref){
  final repo = YearListRepository().getYearListDetails();
  return repo;
});

final selectedYearProvider = StateProvider<String?>((ref) => '2026');


final selectedYearStandingsProvider = StateProvider<String?> ((ref)=> '2026');