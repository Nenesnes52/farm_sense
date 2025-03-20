import 'package:farm_sense/farm_sense_app.dart';
import 'package:farm_sense/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  locator.allReady().then((_) async {
    if (kDebugMode) {
      print('Semua instance yang terdaftar: ${locator.toString()}');
    }
  });
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
  initializeDateFormatting('id_ID', null)
      .then((_) => runApp(const FarmSenseApp()));
}
