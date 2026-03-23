import 'package:f1_app/models/constructorStanding.dart';
import 'package:f1_app/models/drivers_Standing.dart';
import 'package:f1_app/models/season_model.dart';
import 'package:f1_app/repositories/constructors.dart';
import 'package:f1_app/repositories/driver_standing.dart';
import 'package:f1_app/repositories/season.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final homeDataProvider = FutureProvider<({List<Season> races, List<ConstructorStanding> constructorStandings , List<DriverStanding> driverStandings})>((ref) async {
  final results = await Future.wait([
    SeasonRepository().getSeasonDetails('${(DateTime.now().year)}') ,
    ConstructorStandingsRepository().getConstructorStanding('${(DateTime.now().year)}'
    ),
    DriverStandingsRepository().getDriverStandings('${(DateTime.now().year)}'),
  ]);

  return (
  races: results[0] as List<Season>,
  constructorStandings: (results[1] as List<ConstructorStanding>).take(5).toList(),
  driverStandings: (results[2] as List<DriverStanding>).take(5).toList(),
  );

});