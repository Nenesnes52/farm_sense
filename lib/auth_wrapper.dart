import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:farm_sense/pages/authentication.dart';
import 'package:farm_sense/pages/main_menu.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          // WidgetsBinding.instance.addPostFrameCallback((_) {
          //   if (context.mounted) {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       SnackBar(
          //         content:
          //             Text('Selamat Datang Kembali, ${snapshot.data!.email}'),
          //         backgroundColor: Colors.green,
          //       ),
          //     );
          //   }
          // });
          return const MainMenu();
        } else {
          // WidgetsBinding.instance.addPostFrameCallback((_) {
          //   if (context.mounted) {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(
          //         content: Text('Silakan login'),
          //         backgroundColor: Colors.blue,
          //       ),
          //     );
          //   }
          // });
          return Authentication();
        }
      },
    );
  }
}
