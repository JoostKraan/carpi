import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:libserialport/libserialport.dart';

class SerialReaderProvider extends ChangeNotifier {
  static final String portName = dotenv.env['PORT_NAME']!;
  WebSocketChannel? channel;
  Timer? _reconnectTimer;
  bool _isConnected = false;

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
    _initializeWebSocket();

    final ports = SerialPort.availablePorts;

    if (!ports.contains(portName)) {
      print('ERROR: Port $portName not found in available ports');
      return;
    }

    esp32Port = SerialPort(portName);

    Future.delayed(const Duration(seconds: 2), () {
      _startReading();
    });
  }

  void _initializeWebSocket() {
    try {
      channel = WebSocketChannel.connect(
        Uri.parse('ws://192.168.1.69:8765'),
      );

      channel!.stream.listen(
            (data) {
          _isConnected = true;
          print('WebSocket connected successfully');
        },
        onError: (error) {
          print('WebSocket error: $error');
          _isConnected = false;
          _scheduleReconnect();
        },
        onDone: () {
          print('WebSocket connection closed');
          _isConnected = false;
          _scheduleReconnect();
        },
      );

    } catch (e) {
      print('Failed to initialize WebSocket: $e');
      _isConnected = false;
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      _initializeWebSocket();
    });
  }

  void _startReading() {
    try {
      if (!esp32Port.openReadWrite()) {
        print('Failed to open serial port: ${SerialPort.lastError}');
        return;
      }

      final config = SerialPortConfig()
        ..baudRate = 115200
        ..bits = 8
        ..parity = SerialPortParity.none
        ..stopBits = 1
        ..rts = SerialPortRts.flowControl
        ..cts = SerialPortCts.flowControl
        ..dsr = SerialPortDsr.flowControl
        ..dtr = SerialPortDtr.flowControl
        ..setFlowControl(SerialPortFlowControl.none);

      try {
        esp32Port.config = config;
      } catch (configError) {
        print('Failed to set full config, trying minimal config: $configError');
        try {
          final minimalConfig = SerialPortConfig()
            ..baudRate = 115200;
          esp32Port.config = minimalConfig;
        } catch (minimalError) {
          print('Even minimal config failed: $minimalError');
        }
      }

      Future.delayed(const Duration(milliseconds: 100), () {
        _setupReader();
      });

    } catch (e, stackTrace) {
      print('Exception during _startReading: $e');
      print('Stack trace: $stackTrace');
    }
  }

  void _setupReader() {
    try {
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
          print('Serial read error: $e');
          print('Stack trace: $stackTrace');
        },
        onDone: () => print('Serial reader closed'),
      );

      isReading = true;
      print('Serial reader started successfully');
    } catch (e, stackTrace) {
      print('Exception during _setupReader: $e');
      print('Stack trace: $stackTrace');
    }
  }

  void _processLine(String line) {
    if (_isConnected && channel != null) {
      try {
        channel!.sink.add(line);
      } catch (e) {
        print('Failed to send to WebSocket: $e');
        _isConnected = false;
      }
    }

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
      print('Invalid data format: expected 6 parts, got ${parts.length}');
    }
  }

  @override
  void dispose() {
    try {
      isReading = false;
      _reconnectTimer?.cancel();
      reader?.close();
      esp32Port.close();
      esp32Port.dispose();
      channel?.sink.close();
      _dataController.close();
      super.dispose();
    } catch (e) {
      print('Exception during dispose: $e');
    }
  }
}