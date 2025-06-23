import 'package:flutter/material.dart';

class VolumeProvider with ChangeNotifier {
  double _volume = 0.5;

  double get volume => _volume;

  set volume(double newVolume) {
    if (_volume != newVolume) {
      _volume = newVolume;
      notifyListeners();
    }
  }
}