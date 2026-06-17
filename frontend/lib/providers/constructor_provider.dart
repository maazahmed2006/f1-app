import 'package:f1_app/models/constructorStanding.dart';
import 'package:f1_app/models/constructors_model.dart';
import 'package:f1_app/providers/yearListProvider.dart';
import 'package:f1_app/repositories/constructors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final constructorProvider = FutureProvider <List<Constructor>> ((ref) async {
  final repo = await ConstructorRepository().getConstructorDetails();
  return repo;
});

final constructorStandingsProvider = FutureProvider<List<ConstructorStanding>>((ref) async {
  final selectedYear = ref.watch(selectedYearStandingsProvider);
  return ConstructorStandingsRepository().getConstructorStanding(selectedYear ?? '2026');
});