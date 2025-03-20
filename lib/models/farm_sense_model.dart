import 'package:flutter/foundation.dart';

class FarmSenseModel extends ChangeNotifier {
  bool? _isBusy = false;
  bool? get isBusy => _isBusy;
  set isBusy(bool? value) {
    if (_isBusy != value) {
      _isBusy = value;
      notifyListeners();
    }
  }
}
