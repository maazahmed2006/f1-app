import 'package:f1_app/providers/yearListProvider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/drivers_Standing.dart';
import '../repositories/driver_standing.dart';

final driverStandingsProvider = FutureProvider<List<DriverStanding>>((ref) async {
  final selectedYear = ref.watch(selectedYearStandingsProvider);
  return DriverStandingsRepository().getDriverStandings(selectedYear ?? '2026');
});