import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class MediaWebSocket {
  final String url;
  late WebSocketChannel _channel;

  final _metadataController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get metadataStream => _metadataController.stream;

  MediaWebSocket(this.url);

  void connect() {
    _channel = WebSocketChannel.connect(Uri.parse(url));

    _channel.stream.listen(
          (message) {
        try {
          if (message is String && message.trim().startsWith('{')) {
            final decoded = jsonDecode(message); // <- no replaceAll here!
            if (decoded is Map<String, dynamic>) {
              _metadataController.add(decoded);
            }
          }
        } catch (e) {
          print('Error decoding message: $e');
          print('Raw message: $message');
        }
      },
      onDone: () {
        print('WebSocket connection closed');
        _metadataController.close();
      },
      onError: (error) {
        print('WebSocket error: $error');
        _metadataController.addError(error);
      },
    );

  }

  void sendCommand(String command) {

    _channel.sink.add(command);
  }

  void close() {
    _channel.sink.close();
    _metadataController.close();
  }
}
