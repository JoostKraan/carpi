import 'dart:ui';

class Constants {

  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color errorColor;
  final Color successColor;
  final Color fontColor;
  final Color iconColor;

  final double iconSize;
  final double textSize;
  final String mapurl;


  Constants(bool dark)
      : primaryColor = dark ? const Color(0xBE1A1A1A) : const Color(0x83F6F6F4),
        secondaryColor = dark ? const Color(0xFF333333) : const Color(0xD19B9B9B),
        accentColor = const Color(0xFF0E79B2),
        errorColor = const Color(0xFFEF476F),
        successColor = const Color(0xFF009B72),
        fontColor =  dark ? const Color(0xFFFFFFFF) : const Color(0xD10E1314)  ,
        iconColor =  dark ? const Color(0xFFFFFFFF) : const Color(0xD10E1314),
        iconSize = 25,
        textSize = 16,
        mapurl = dark ? "https://tile.jawg.io/jawg-dark/{z}/{x}/{y}{r}.png?access-token=ME95gmQBq6fVpZys7OtD6VJLMx706vzQRALB4oZiea5VnbQ7rfH9xjiOIu5wyy5b"
                      : "https://tile.jawg.io/jawg-light/{z}/{x}/{y}{r}.png?access-token=ME95gmQBq6fVpZys7OtD6VJLMx706vzQRALB4oZiea5VnbQ7rfH9xjiOIu5wyy5b";
}
