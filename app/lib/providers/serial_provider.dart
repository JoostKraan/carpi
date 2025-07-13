import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SerialReaderProvider extends ChangeNotifier {

  static final String portName = dotenv.env['PORT_NAME']! ;
  final channel = WebSocketChannel.connect(
    Uri.parse('ws://192.168.1.69:8765'),
  );

  late final SerialPort esp32Port;
  SerialPortReader? reader;

  String temp1 = '';
  String temp2 = '';
  double lat = 0.0;
  double lon = 0.0;
  bool hasLocation = false;

  final StreamController<String> _dataController = StreamController<String>.broadcast();
  Stream<String> get dataStream => _dataController.stream;

  // Buffer for incomplete data
  String _buffer = '';

  SerialReaderProvider() {
    esp32Port = SerialPort(portName);
    print(portName);
    print("Initializing SerialReaderProvider");
    _startReading();
  }

  void _startReading() {
    try {
      if (esp32Port.isOpen) {
        esp32Port.close();
      }

      final config = esp32Port.config;
      config.baudRate = 115200;
      esp32Port.config = config;

      if (!esp32Port.openReadWrite()) {
        print('❌ Failed to open serial port: ${SerialPort.lastError}');
        return;
      }

      reader = SerialPortReader(esp32Port);

      reader!.stream.listen(
            (data) {
          // Convert bytes to string and add to buffer
          final chunk = String.fromCharCodes(data);
          _buffer += chunk;

          // Process complete lines
          while (_buffer.contains('\n')) {
            final lineEnd = _buffer.indexOf('\n');
            final line = _buffer.substring(0, lineEnd).trim();
            _buffer = _buffer.substring(lineEnd + 1);

            if (line.isNotEmpty) {
              _processLine(line);
            }
          }
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

  void _processLine(String line) {
    print('Processing line: $line');
    channel.sink.add(line);

    final parts = line.split(',');

    if (parts.length >= 6) {
      String latStr = parts[2];
      String lonStr = parts[3];

      if (latStr == 'null' || lonStr == 'null') {
        hasLocation = false;
        lat = 0.0;
        lon = 0.0;
      } else {
        lat = double.tryParse(latStr) ?? 0.0;
        lon = double.tryParse(lonStr) ?? 0.0;
        hasLocation = (lat != 0.0 || lon != 0.0);
      }
      temp1 = (double.tryParse(parts[4])?.toInt() ?? 0).toString();
      temp2 = (double.tryParse(parts[5])?.toInt() ?? 0).toString();


      notifyListeners();
    } else {
      print('Invalid data format: expected 6 parts, got ${parts.length}');
    }

    _dataController.add(line);
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