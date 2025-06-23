import 'package:flutter/material.dart';
import '../services/theme.dart';


class ConstantsProvider extends ChangeNotifier {
  late Constants _constants;
  late bool _isDarkMode;

  ConstantsProvider({bool initialDarkMode = false}) {
    print("Initial dark mode? $initialDarkMode");
    _isDarkMode = initialDarkMode;
    _constants = Constants(_isDarkMode);
  }

  Constants get constants => _constants;
  bool get isDarkMode => _isDarkMode;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _constants = Constants(_isDarkMode);
    notifyListeners();
  }
}

