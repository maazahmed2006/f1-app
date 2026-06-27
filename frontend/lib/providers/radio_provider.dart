
import 'package:f1_app/models/radio_model.dart';
import 'package:f1_app/repositories/radio_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final radioProvider = FutureProvider<List<RadioData>> ((ref) async{
    return RadioDataRepository().getRadioData();
});