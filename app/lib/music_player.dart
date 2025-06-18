import 'package:app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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

  @override
  void initState() {
    super.initState();
    mediaWebSocket = MediaWebSocket('ws://192.168.1.126:8765');
    mediaWebSocket.connect();

    mediaWebSocket.metadataStream.listen((data) {
      if (!mounted) return;
      setState(() {
        title = data['title'] ?? 'Unknown Title';
        artist = data['artist'] ?? 'Unknown Artist';
        album = data['album'] ?? 'Unknown Album';
      });
    });
  }

  @override
  void dispose() {

    mediaWebSocket.close();
    super.dispose();
  }

  @override

  Widget build(BuildContext context) {
    final constants = Constants(true);
    final Size screenSize = MediaQuery.of(context).size;
    return  Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: constants.secondaryColor,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      height: screenSize.height / 5,
      width: screenSize.width / 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: constants.fontColor,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Text(
                style: TextStyle(
                  color: constants.fontColor,
                ),
                artist,
              ),
            ],
          ),
          Row(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10,bottom: 10),
                child: SizedBox(
                  width: screenSize.width / 5,
                  height: 3,
                  child: LinearProgressIndicator(
                    value: 1,
                    color: constants.accentColor,
                  ),
                ),
              ),
            ],
          ),
          Row(
            spacing: 20,
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              FloatingActionButton.small(

                elevation: 0,
                backgroundColor:
                constants.accentColor,
                foregroundColor:
                constants.iconColor,
                onPressed: null,
                child: SvgPicture.asset(
                  width: constants.iconSize,
                  height: constants.iconSize,
                  'assets/icons/shuffle-disabled.svg',
                  color: constants.iconColor,
                ),
              ),
              FloatingActionButton.small(
                elevation: 0,
                backgroundColor:
                constants.accentColor,
                foregroundColor:
                constants.iconColor,
                onPressed: null,
                child: SvgPicture.asset(
                  'assets/icons/skip-previous.svg',
                  width: constants.iconSize,
                  height: constants.iconSize,
                  color: constants.iconColor,
                ),
              ),
              FloatingActionButton.small(
                elevation: 0,
                backgroundColor:
                constants.accentColor,
                foregroundColor:
                constants.iconColor,
                onPressed: null,
                child: SvgPicture.asset(
                  width: constants.iconSize,
                  height: constants.iconSize,
                  'assets/icons/play.svg',
                  color: constants.iconColor,
                ),
              ),
              FloatingActionButton.small(
                elevation: 0,
                backgroundColor:
                constants.accentColor,
                foregroundColor:
                constants.iconColor,
                onPressed: null,
                child: SvgPicture.asset(
                  width: constants.iconSize,
                  height: constants.iconSize,
                  'assets/icons/skip-next.svg',
                  color: constants.iconColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
