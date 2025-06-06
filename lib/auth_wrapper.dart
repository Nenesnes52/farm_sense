// Contoh sederhana AuthWrapper (bisa diletakkan di file terpisah)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:farm_sense/pages/main_menu.dart'; // Halaman utama Anda
// import 'package:farm_sense/pages/authentication.dart'; // Halaman login Anda

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Tampilkan loading indicator jika diperlukan
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          // Pengguna sudah login, arahkan ke halaman utama
          // return const MainMenu(); // Ganti dengan halaman utama Anda
          if (kDebugMode) {
            print("Pengguna sudah login: ${snapshot.data!.email}");
          }
          // Navigasi ke halaman utama Anda di sini
          // Contoh: return MainMenu();
          // Untuk sementara, kita tampilkan pesan saja
          return Scaffold(
              body: Center(
                  child:
                      Text("Selamat Datang Kembali, ${snapshot.data!.email}")));
        }
        // Pengguna belum login, arahkan ke halaman autentikasi
        // return Authentication(); // Ganti dengan halaman login Anda
        if (kDebugMode) {
          print("Pengguna belum login.");
        }
        // Navigasi ke halaman login Anda di sini
        // Contoh: return Authentication();
        // Untuk sementara, kita tampilkan pesan saja
        return Scaffold(body: Center(child: Text("Silakan Login")));
      },
    );
  }
}
