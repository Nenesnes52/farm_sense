import 'package:farm_sense/farm_sense_app.dart';
import 'package:farm_sense/firebase_options.dart';
import 'package:farm_sense/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
