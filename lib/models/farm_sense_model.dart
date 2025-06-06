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
        onFailed(e.message ?? 'Terjadi kesalahan autentikasi.');
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
        onFailed(e.message ?? 'Terjadi kesalahan saat mendaftar.');
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
