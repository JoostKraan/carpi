import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/theme.dart';


class ConstantsProvider extends ChangeNotifier {
  late Constants _constants;
  late bool _isDarkMode;

  ConstantsProvider._();

  static Future<ConstantsProvider> create() async {
    final provider = ConstantsProvider._();
    provider._isDarkMode = await provider._readData() ?? false;
    provider._constants = Constants(provider._isDarkMode);
    return provider;
  }

  Future<void> _writeData(bool theme) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('theme', theme);
  }

  Future<bool?> _readData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('theme');
  }

  Constants get constants => _constants;
  bool get isDarkMode => _isDarkMode;

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    _constants = Constants(_isDarkMode);
    await _writeData(_isDarkMode);
    notifyListeners();
  }
}

