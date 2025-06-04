import 'dart:async';
import 'dart:convert' as convert;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class FarmSenseModel extends ChangeNotifier {
  final _url = Uri.https(
    'api.zonainovasi.site',
    '/',
  );

  bool? _isBusy = false;
  bool? get isBusy => _isBusy;
  set isBusy(bool? value) {
    if (_isBusy != value) {
      _isBusy = value;
      notifyListeners();
    }
  }

  Future<void> handleSignIn({
    required String username,
    required String password,
    Function()? onSuccess,
    Function()? onFailed,
  }) async {
    isBusy = true;

    final completer = Completer();
    var response = await http.post(_url.replace(path: '/auth/sign-in'),
        body: convert.json.encode(
          {
            'username': username,
            'password': password,
          },
        ),
        headers: {'Content-Type': 'application/json'});
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode < 400) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      if (kDebugMode) {
        print(jsonResponse);
      }
      if (onSuccess != null) onSuccess();
    } else {
      if (onFailed != null) onFailed();
      completer.complete(false);
    }
    isBusy = false;
    return await completer.future;
  }

  Future<void> handleSignUp({
    required String name,
    required String email,
    required String username,
    required String password,
    Function()? onSuccess,
    Function()? onFailed,
  }) async {
    isBusy = true;
    final completer = Completer();
    var response = await http.post(
      _url.replace(path: '/auth/sign-up'),
      body: convert.json.encode(
        {
          'name': name,
          'email': email,
          'username': username,
          'password': password,
        },
      ),
      headers: {'Content-Type': 'application/json'},
    );
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode < 400) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      if (kDebugMode) {
        print(jsonResponse);
      }
      if (onSuccess != null) onSuccess();
      completer.complete(true);
    } else {
      if (onFailed != null) onFailed();
      completer.complete(false);
    }
    isBusy = false;
    return await completer.future;
  }
}
