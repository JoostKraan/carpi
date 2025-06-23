import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class SerialReaderProvider extends ChangeNotifier {
  static const String portName = 'COM3';

  late final SerialPort esp32Port;
  SerialPortReader? reader;

  String temp1 = '';
  String temp2 = '';
  double lat = 0.0;
  double lon = 0.0;
  bool hasLocation = false;

  final StreamController<String> _dataController = StreamController<String>.broadcast();
  Stream<String> get dataStream => _dataController.stream;

  SerialReaderProvider() {
    esp32Port = SerialPort(portName);
    print("Initializing SerialReaderProvider");
    _startReading();
  }

  void _startReading() {
    try {
      if (esp32Port.isOpen) {
        esp32Port.close();
      }

      if (!esp32Port.openReadWrite()) {
        print('❌ Failed to open serial port: ${SerialPort.lastError}');
        return;
      }

      reader = SerialPortReader(esp32Port);

      reader!.stream.listen(
            (data) {
          final chunk = String.fromCharCodes(data).trim();
          final parts = chunk.split(',');

          if (parts.length >= 6) {
            lat = (double.tryParse(parts[2]) ?? 0.0);
            lon = (double.tryParse(parts[3]) ?? 0.0);
            temp1 = (double.tryParse(parts[4])?.toInt() ?? 0).toString();
            temp2 = (double.tryParse(parts[5])?.toInt() ?? 0).toString();

            if (lat == 'null' || lon == 'null'){
              hasLocation = false;
            }
            else{
              hasLocation = true;
            }

            print(chunk);
            notifyListeners();
          }
          else
            print("Something wong");
          print(chunk);

          _dataController.add(chunk);
        },
        onError: (error) {
          print('❌ Serial read error: $error');
          _dataController.addError(error);
        },
      );
    } catch (e) {
      print('❌ Exception while opening/reading serial port: $e');
      _dataController.addError(e);
    }
  }

  @override
  void dispose() {
    try {
      reader?.close();
      if (esp32Port.isOpen) {
        esp32Port.close();
      }
      esp32Port.dispose();
      _dataController.close();
      super.dispose();
    } catch (e) {
      print('❌ Exception during dispose: $e');
    }
  }
}
