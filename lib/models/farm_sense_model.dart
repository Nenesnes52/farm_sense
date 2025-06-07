import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FarmSenseModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool? _isBusy = false;
  bool? get isBusy => _isBusy;
  set isBusy(bool? value) {
    if (_isBusy != value) {
      _isBusy = value;
      notifyListeners();
    }
  }

  String _translateFirebaseAuthErrorMessage(
      String errorCode, String defaultMessage) {
    switch (errorCode) {
      case 'invalid-email':
        return 'Format email yang Anda masukkan tidak valid.';
      case 'user-not-found':
        return 'Pengguna dengan email tersebut tidak ditemukan.';
      case 'wrong-password':
        return 'Password yang Anda masukkan salah.';
      case 'email-already-in-use':
        return 'Email ini sudah digunakan oleh akun lain.';
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
      case 'operation-not-allowed':
        return 'Operasi ini tidak diizinkan. Hubungi dukungan.';
      case 'user-disabled':
        return 'Akun pengguna ini telah dinonaktifkan.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan gagal. Silakan coba lagi nanti atau reset password Anda.';
      case 'network-request-failed':
        return 'Gagal terhubung ke server. Periksa koneksi internet Anda.';
      case 'invalid-credential':
        return 'Email atau password yang Anda masukkan salah.';
      // Tambahkan case lain sesuai kebutuhan
      default:
        if (kDebugMode) {
          print('Firebase Error Code: $errorCode, Message: $defaultMessage');
        }
        return defaultMessage; // Mengembalikan pesan default jika tidak ada terjemahan spesifik
    }
  }

  Future<void> handleSignIn({
    required String email,
    required String password,
    Function(User user)? onSuccess,
    Function(String errorMessage)? onFailed,
  }) async {
    isBusy = true;

    final completer = Completer();
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        if (onSuccess != null) onSuccess(userCredential.user!);
        completer.complete(true);
      } else {
        if (onFailed != null) {
          onFailed('Gagal masuk, pengguna tidak ditemukan setelah berhasil.');
        }
        completer.complete(false);
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase SignIn Error: ${e.message}');
      }
      if (onFailed != null) {
        onFailed(_translateFirebaseAuthErrorMessage(
            e.code, e.message ?? 'Terjadi kesalahan autentikasi.'));
      }
      completer.complete(false);
    } catch (e) {
      if (kDebugMode) {
        print('Generic SignIn Error: $e');
      }
      if (onFailed != null) onFailed('Terjadi kesalahan yang tidak terduga.');
      completer.complete(false);
    }
    isBusy = false;
    return await completer.future;
  }

  Future<void> handleSignUp({
    String? name,
    required String email,
    String? username,
    required String password,
    Function(User user)? onSuccess,
    Function(String errorMessage)? onFailed,
  }) async {
    isBusy = true;
    final completer = Completer();
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Setelah user dibuat, Anda bisa menyimpan 'name' dan 'username'
      // ke Firestore atau Realtime Database jika diperlukan, menggunakan userCredential.user!.uid
      if (userCredential.user != null) {
        // Contoh: await userCredential.user!.updateDisplayName(name); (jika ingin update display name Firebase)
        if (onSuccess != null) onSuccess(userCredential.user!);
        completer.complete(true);
      } else {
        if (onFailed != null) {
          onFailed('Gagal mendaftar, pengguna tidak dibuat setelah berhasil.');
        }
        completer.complete(false);
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase SignUp Error: ${e.message}');
      }
      if (onFailed != null) {
        onFailed(_translateFirebaseAuthErrorMessage(
            e.code, e.message ?? 'Terjadi kesalahan saat mendaftar.'));
      }
      completer.complete(false);
    } catch (e) {
      if (kDebugMode) {
        print('Generic SignUp Error: $e');
      }
      if (onFailed != null) {
        onFailed('Terjadi kesalahan yang tidak terduga saat mendaftar.');
      }

      completer.complete(false);
    }
    isBusy = false;
    return await completer.future;
  }
}
