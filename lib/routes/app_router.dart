import 'package:farm_sense/auth_wrapper.dart';
import 'package:farm_sense/pages/authentication.dart';
import 'package:farm_sense/pages/main_menu.dart';
import 'package:farm_sense/pages/splash.dart';
import 'package:farm_sense/routes/route_name.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static Map<String, WidgetBuilder> get routes {
    return {
      mainRoute: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as int?;
        return MainMenu(initPageIndex: args);
      },
      // homeRoute: (context) => Home(),
      // farmRoute: (context) => Farm(),
      // farmInfoRoute: (context) => FarmInfo(),
      // controlRoute: (context) => Control(),
      // controlToolsRoute: (context) => ControlTools(),
      // cameraRoute: (context) => ControlTools(),
      splashRoute: (context) => Splash(),
      authRoute: (context) => Authentication(),
      wrapperRoute: (context) => AuthWrapper(),
    };
  }
}
