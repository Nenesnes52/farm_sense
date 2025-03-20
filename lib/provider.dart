import 'package:farm_sense/models/farm_sense_model.dart';
import 'package:get_it/get_it.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<FarmSenseModel>(() => FarmSenseModel());
}
