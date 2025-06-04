import 'package:farm_sense/routes/app_router.dart';
import 'package:farm_sense/routes/route_name.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FarmSenseApp extends StatelessWidget {
  const FarmSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Farm Sense',
      routes: AppRouter.routes,
      initialRoute: splashRoute,
      theme: ThemeData(
        // fontFamily: GoogleFonts.urbanist().fontFamily,

        // textTheme: GoogleFonts.plusJakartaSansTextTheme(
        //   Theme.of(context).textTheme,
        // ),
        textTheme: TextTheme().copyWith(
          bodySmall: TextStyle(
              color: Color.fromRGBO(2, 84, 100, 1),
              fontFamily: GoogleFonts.plusJakartaSans().fontFamily),
          bodyMedium: TextStyle(
              color: Color.fromRGBO(2, 84, 100, 1),
              fontFamily: GoogleFonts.plusJakartaSans().fontFamily),
          bodyLarge: TextStyle(
              color: Color.fromRGBO(2, 84, 100, 1),
              fontFamily: GoogleFonts.plusJakartaSans().fontFamily),
          labelSmall: TextStyle(
              color: Color.fromRGBO(2, 84, 100, 1),
              fontFamily: GoogleFonts.plusJakartaSans().fontFamily),
          labelMedium: TextStyle(
              color: Color.fromRGBO(2, 84, 100, 1),
              fontFamily: GoogleFonts.plusJakartaSans().fontFamily),
          labelLarge: TextStyle(
              color: Color.fromRGBO(2, 84, 100, 1),
              fontFamily: GoogleFonts.plusJakartaSans().fontFamily),
          displaySmall: TextStyle(
              color: Color.fromRGBO(2, 84, 100, 1),
              fontFamily: GoogleFonts.plusJakartaSans().fontFamily),
          displayMedium: TextStyle(
              color: Color.fromRGBO(2, 84, 100, 1),
              fontFamily: GoogleFonts.plusJakartaSans().fontFamily),
          displayLarge: TextStyle(
              color: Color.fromRGBO(2, 84, 100, 1),
              fontFamily: GoogleFonts.plusJakartaSans().fontFamily),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(2, 84, 100, 1),
        ),
        useMaterial3: true,
      ),
    );
  }
}
