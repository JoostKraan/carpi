import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:libserialport/libserialport.dart';

class SerialReaderProvider extends ChangeNotifier {
  static final String portName = dotenv.env['PORT_NAME']!;
  final channel = WebSocketChannel.connect(
    Uri.parse('ws://192.168.1.69:8765'),
  );

  late final SerialPort esp32Port;
  SerialPortReader? reader;
  bool isReading = false;

  String temp1 = '';
  String temp2 = '';
  double lat = 0.0;
  double lon = 0.0;
  bool hasLocation = false;

  final StreamController<String> _dataController = StreamController<String>.broadcast();
  Stream<String> get dataStream => _dataController.stream;

  String _buffer = '';

  SerialReaderProvider() {
    print("Initializing SerialReaderProvider with port: $portName");

    // Debug list of ports
    final ports = SerialPort.availablePorts;
    print("Available ports: ${ports.isEmpty ? '(none)' : ''}");
    for (final p in ports) {
      print(" - $p");
    }

    if (!ports.contains(portName)) {
      print("⚠️ ERROR: Port '$portName' not found in available ports.");
      return;
    }

    esp32Port = SerialPort(portName);

    try {
      // Set config FIRST

    } catch (e, stack) {
      print('⚠️ Failed to set SerialPort config: $e');
      print('Stack trace:\n$stack');
      return;
    }

    Future.delayed(const Duration(seconds: 2), () {
      _startReading();
    });
  }

  void _startReading() {
    try {
      // ✅ Step 1: Create and set config BEFORE opening
      final config = SerialPortConfig()
        ..baudRate = 115200;
      esp32Port.config = config;

      // ✅ Step 2: Open the port
      if (!esp32Port.openReadWrite()) {
        print('❌ Failed to open serial port: ${SerialPort.lastError}');
        return;
      }

      print('✅ Serial port opened: ${esp32Port.name}');

      // ✅ Step 3: Set up the reader
      reader = SerialPortReader(esp32Port);
      reader!.stream.listen(
            (Uint8List data) {
          final chunk = utf8.decode(data, allowMalformed: true);
          _buffer += chunk;

          while (_buffer.contains('\n')) {
            final idx = _buffer.indexOf('\n');
            final line = _buffer.substring(0, idx).trim();
            _buffer = _buffer.substring(idx + 1);
            if (line.isNotEmpty) _processLine(line);
          }
        },
        onError: (e, stackTrace) {
          print('❌ Serial read error: $e');
          print('Stack trace:\n$stackTrace');
        },
        onDone: () => print('ℹ️ Serial reader closed'),
      );
    } catch (e, stackTrace) {
      print('❌ Exception during _startReading: $e');
      print('Stack trace:\n$stackTrace');
    }
  }




  void _processLine(String line) {
    print('📥 Line received: $line');
    channel.sink.add(line);
    _dataController.add(line);

    final parts = line.split(',');

    if (parts.length >= 6) {
      final latStr = parts[2];
      final lonStr = parts[3];

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
      print('⚠️ Invalid data format: expected 6 parts, got ${parts.length}');
    }
  }

  @override
  void dispose() {
    try {
      isReading = false;
      esp32Port.close();
      esp32Port.dispose();
      _dataController.close();
      super.dispose();
    } catch (e) {
      print('⚠️ Exception during dispose: $e');
    }
  }
}
