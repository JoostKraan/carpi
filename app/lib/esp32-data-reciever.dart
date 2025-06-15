import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WebSocketService {
 
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  late final WebSocketChannel _channel;
  final _url = 'ws://${dotenv.get('RECEIVER')}:8000/ws';

  double? lat;
  double? lng;
  double? temp1;
  double? temp2;

  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  WebSocketService._internal() {
    _channel = WebSocketChannel.connect(Uri.parse(_url));
    _channel.stream.listen((event) {
      print('[WS RECEIVED]: $event');

      try {
        final decoded = jsonDecode(event);
        if (decoded is Map<String, dynamic>) {
          lat = decoded['lat'];
          lng = decoded['lng'];
          temp1 = decoded['temp1'];
          temp2 = decoded['temp2'];

          _controller.add(decoded);
        } else {
          throw Exception('Expected Map<String, dynamic>, got: ${decoded.runtimeType}');
        }
      } catch (e) {
        print('[WS ERROR]: $e');
      }
    });
  }
  Stream<Map<String, dynamic>> get stream => _controller.stream;
  void dispose() {
    _channel.sink.close();
    _controller.close();
  }
}
