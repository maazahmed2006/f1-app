// ye wala provider ko gesture sei read krei gei driver id
import 'package:f1_app/models/drivers_career_results.dart';
import 'package:f1_app/repositories/driver_career_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final selectedDriverProvider = StateProvider<String> ((ref){
  return '';
});

// is provider wee are going to return the results fetched

final resultsProvider = FutureProvider<DriverCareerStats> ((ref){
  String driverId = ref.watch(selectedDriverProvider);
  return DriverCareerRepository().getDriverCareerResults(driverId);
});