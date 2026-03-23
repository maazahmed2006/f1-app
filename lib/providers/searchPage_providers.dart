

import 'package:f1_app/models/drivers_model.dart';
import 'package:f1_app/repositories/searching_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final queryProvider = StateProvider<String> ((ref){
  return "";
});

final driversListProvider = FutureProvider<List<Drivers>> ((ref){
  return DriverListRepository().getDriversList();
});


final filteredDriversProvider = Provider<List<Drivers>?>((ref) {
  final query = ref.watch(queryProvider).toLowerCase().trim();
  final driversAsync = ref.watch(driversListProvider);

  return driversAsync.when(
    data: (drivers) {
      if (query.isEmpty) return drivers;
      return drivers.where((driver) {
        final fullName = '${driver.givenName} ${driver.familyName}'.toLowerCase();
        return fullName.contains(query);
      }).toList();
    },
    loading: () => null,
    error: (_, __) => <Drivers>[], // ← typed
  );
});