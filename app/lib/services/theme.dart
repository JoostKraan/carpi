import 'dart:ui';
import 'package:flutter/material.dart';
class Constants{

  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color errorColor;
  final Color successColor;
  final Color fontColor;
  final Color iconColor;
  final double iconSize;
  final double fontSize;
  final String mapurl;

  final bool isDarkMode;

  Constants(this.isDarkMode)

      : primaryColor = isDarkMode ? const Color(0xBE1A1A1A) : const Color(
      0xBFF6F6F4),
        secondaryColor = isDarkMode ? const Color(0xFF333333) : const Color(0xD19B9B9B),
        accentColor = const Color(0xFF0E79B2),
        errorColor = const Color(0xFFEF476F),
        successColor = const Color(0xFF009B72),
        fontColor =  isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xD10E1314)  ,
        iconColor =  isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xD10E1314),
        iconSize = 25,
        fontSize = 18,
        mapurl = isDarkMode ? "https://tile.jawg.io/jawg-dark/{z}/{x}/{y}{r}.png?access-token=ME95gmQBq6fVpZys7OtD6VJLMx706vzQRALB4oZiea5VnbQ7rfH9xjiOIu5wyy5b"
                      : "https://tile.jawg.io/jawg-light/{z}/{x}/{y}{r}.png?access-token=ME95gmQBq6fVpZys7OtD6VJLMx706vzQRALB4oZiea5VnbQ7rfH9xjiOIu5wyy5b";
}
