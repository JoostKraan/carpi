import 'dart:io';
import 'dart:developer';
import 'package:flutter/foundation.dart';

class Services{
  final ValueNotifier<bool> hasInternet = ValueNotifier(true);
  Future<void> checkForInternet() async {
    while(true){
      try{
        await Future.delayed(const Duration(seconds: 5));
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          hasInternet.value = true;
        }
      }
      on SocketException catch (_) {
        hasInternet.value = false;
        log('not connected $hasInternet');

      }
    }
  }
  }
  


