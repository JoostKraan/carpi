import 'package:flutter/material.dart';
import '../theme.dart';


class ConstantsProvider extends ChangeNotifier {
  late Constants _constants;

  ConstantsProvider({bool initialDarkMode = true}) {
    _constants = Constants(initialDarkMode);
  }

  Constants get constants => _constants;

  bool get isDarkMode => _constants.isDarkMode;

  void toggleDarkMode() {
    _constants = Constants(!_constants.isDarkMode);
    notifyListeners();
  }
}
