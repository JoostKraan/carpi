// lib/providers/volume_provider.dart
import 'package:flutter/material.dart';
import 'package:volume_controller/volume_controller.dart';

class VolumeProvider extends ChangeNotifier {
  double _vol = 1.0;
  VolumeProvider() {
    // fetch initial value
    VolumeController.instance.getVolume().then((v) {
      _vol = v; notifyListeners();

    });
    // subscribe to hardware / external changes
    VolumeController.instance.addListener((v) {
      _vol = v; notifyListeners();

    }, fetchInitialVolume: false);
  }

  double get volume => _vol;
  set volume(double v) {
    VolumeController.instance.setVolume(v.clamp(0,1));
  }

  @override
  void dispose() {
    VolumeController.instance.removeListener();
    super.dispose();
  }
}
