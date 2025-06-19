import 'dart:async';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class SerialReader {
  static const String portName = 'COM3';
  late SerialPort esp32Port;
  SerialPortReader? reader;

  final StreamController<String> _dataController = StreamController<String>.broadcast();
  Stream<String> get dataStream => _dataController.stream;

  SerialReader() {
    esp32Port = SerialPort(portName);
  }

  void readData() {
    try {
      if (esp32Port.isOpen) {
        esp32Port.close();
      }

      if (!esp32Port.openReadWrite()) {
        print('Failed to open serial port: ${SerialPort.lastError}');
        return;
      }

      reader = SerialPortReader(esp32Port);

      reader!.stream.listen(
            (data) {
          final chunk = String.fromCharCodes(data).trim();
          final fixedChunk = chunk.split(',');
          if (fixedChunk.length >= 4){
            final temp1 = fixedChunk[3];
            final temp2 = fixedChunk[4];
            print("split string : $temp2 $temp1");
            print("default string : $chunk");
          }
          else{
            return;
          }
          _dataController.add(chunk);
        },
        onError: (error) {
          print('Serial read error: $error');
          _dataController.addError(error);
        },
      );
    } catch (e) {
      print('Exception while opening/reading serial port: $e');
      _dataController.addError(e);
    }
  }

  void dispose() {
    try {
      reader?.close();
      if (esp32Port.isOpen) {
        esp32Port.close();
      }
      esp32Port.dispose();
      _dataController.close();
    } catch (e) {
      print('Exception during dispose: $e');
    }
  }
}
