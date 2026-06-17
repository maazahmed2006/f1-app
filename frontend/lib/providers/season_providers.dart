import 'package:f1_app/models/season_model.dart';
import 'package:f1_app/models/winners_model.dart';
import 'package:f1_app/providers/yearListProvider.dart';
import 'package:f1_app/repositories/season.dart';
import 'package:f1_app/repositories/winners.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final seasonProvider = FutureProvider<List<Season>>((ref) async {
  final selectedYear = ref.watch(selectedYearProvider);
  final races = await SeasonRepository().getSeasonDetails(selectedYear ?? '2026');
  return races;
});

final scheduleDataProvider = FutureProvider<({List<Season> races, List<Result> winners})>((ref) async {
  final selectedYear = ref.watch(selectedYearProvider);
  final results = await Future.wait([
    SeasonRepository().getSeasonDetails(selectedYear ?? '2026'),
    WinnerRepository().getWinner(selectedYear ?? '2026'),
  ]);

  return (
  races: results[0] as List<Season>,
  winners: results[1] as List<Result>,
  );
});

