import 'dart:async';

import 'package:farm_sense/models/farm_sense_model.dart';
import 'package:farm_sense/provider.dart';
import 'package:farm_sense/routes/route_name.dart';
import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

class Splash extends StatefulWidget with GetItStatefulWidgetMixin {
  Splash({super.key});
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with GetItStateMixin {
  final model = locator<FarmSenseModel>();

  @override
  void initState() {
    super.initState();

    Timer(
      Duration(milliseconds: 1500),
      () async {
        // final loggedIn = await model.handleRestrict();

        if (mounted) {
          Navigator.pushReplacementNamed(
              context,
              // loggedIn ? mainRoute :
              authRoute);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(2, 84, 100, 1),
            Color.fromRGBO(42, 111, 125, 1),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Image.asset(
            'assets/logo_text.png',
            // color: Colors.white,
            // scale: 112.68 / 70,
          ),
        ),
      ),
    );
  }
}
