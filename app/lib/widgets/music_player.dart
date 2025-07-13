import 'package:app/providers/constants-provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'get_audio.dart';

class MusicPlayer extends StatefulWidget {
  const MusicPlayer({super.key});

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  late MediaWebSocket mediaWebSocket;
  String title = 'No song available';
  String artist = 'No artist available';
  String album = 'Loading...';
  int duration = 0;
  int position = 0;
  bool isPlaying = false;
  List<String> availableCommands = [];

  bool? optimisticIsPlaying;

  @override
  void initState() {
    super.initState();
    mediaWebSocket = MediaWebSocket('ws://192.168.1.126:8765');
    mediaWebSocket.connect();

    mediaWebSocket.metadataStream.listen((data) {
      if (!mounted) return;
      setState(() {
        title = data['metadata']['Title'] ?? 'Unknown Title';
        artist = data['metadata']['Artist'] ?? 'Unknown Artist';
        album = data['metadata']['Album'] ?? 'Unknown Album';
        duration = data['duration'] ?? 0;
        position = data['position'] ?? 0;
        isPlaying = data['isPlaying'] ?? false;
        availableCommands = List<String>.from(data['availableCommands'] ?? []);
        // Reset optimistic override on backend update
        optimisticIsPlaying = null;
      });
    });
  }

  @override
  void dispose() {
    mediaWebSocket.close();
    super.dispose();
  }

  bool _can(String command) => availableCommands.contains(command);

  bool get effectiveIsPlaying => optimisticIsPlaying ?? isPlaying;

  @override
  Widget build(BuildContext context) {
    final constants = context.watch<ConstantsProvider>().constants;
    final Size screenSize = MediaQuery.of(context).size;

    double progressValue = duration > 0 ? position / duration : 0.0;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: constants.secondaryColor),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      height: screenSize.height / 5,
      width: screenSize.width / 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text( overflow: TextOverflow.clip, title, style: TextStyle(color: constants.fontColor)),
          Text(artist, style: TextStyle(color: constants.fontColor)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SizedBox(
              width: screenSize.width / 5,
              height: 3,
              child: LinearProgressIndicator(
                backgroundColor: constants.secondaryColor,
                value: progressValue.clamp(0.0, 1.0),
                color: constants.accentColor,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(
                icon: 'shuffle3.svg',
                onPressed: () => mediaWebSocket.sendCommand('toggle_shuffle'),
                enabled: _can('toggle_shuffle'),
              ),
              _buildControlButton(
                icon: 'skip-previous3.svg',
                onPressed: () => mediaWebSocket.sendCommand('previous'),
                enabled: _can('previous'),
              ),
              _buildControlButton(
                icon: effectiveIsPlaying ? 'pause3.svg' : 'play3.svg',
                onPressed: () {
                  final command = effectiveIsPlaying ? 'pause' : 'play';
                  // Optimistic UI update
                  setState(() {
                    optimisticIsPlaying = !effectiveIsPlaying;
                  });
                  mediaWebSocket.sendCommand(command);
                },
                enabled: _can(effectiveIsPlaying ? 'pause' : 'play'),
              ),
              _buildControlButton(
                icon: 'skip-next3.svg',
                onPressed: () => mediaWebSocket.sendCommand('next'),
                enabled: _can('next'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required String icon,
    required VoidCallback onPressed,
    required bool enabled,
  }) {
    final constants = context.read<ConstantsProvider>().constants;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.3,
        child: FloatingActionButton.small(
          backgroundColor: constants.accentColor,
          foregroundColor: constants.iconColor,
          onPressed: enabled ? onPressed : null,
          child: SvgPicture.asset(
            'assets/icons/$icon',
            width: constants.iconSize,
            height: constants.iconSize,
            color: constants.iconColor,
          ),
        ),
      ),
    );
  }
}
