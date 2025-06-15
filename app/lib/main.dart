import 'dart:ui';

import 'package:app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:app/services.dart';
import 'package:one_clock/one_clock.dart';


Services services = Services();
void main() {
  runApp(const MyApp());
  initialize();
}

void initialize() {
  services.checkForInternet();
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'Manrope',
        dividerTheme: const DividerThemeData(
          color: Colors.transparent,
        ),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool darkmode = true;

  void toggleDarkmode() {
    setState(() {
      darkmode = !darkmode;
    });
  }


  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double containerWidth = screenSize.width / 3;
    final LatLng carLocation = LatLng(52.68697352961828, 6.60489107953327);

    final constants = Constants(darkmode);


    return Scaffold(
      backgroundColor: constants.primaryColor,

      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(1, 1),
                initialZoom: 3.2,
              ),
              children: [
                TileLayer(
                  retinaMode: true,
                  urlTemplate: constants.mapurl,
                  userAgentPackageName: 'com.example.app',
                ),
                Positioned(
                  bottom: 50,
                  right: 0,
                  child: SimpleAttributionWidget(
                    backgroundColor: Color(0x00ffffff),
                    source: Text(
                      style: TextStyle(color: constants.iconColor),
                      'OpenStreetMap contributors',
                    ),
                  ),
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: carLocation,
                      width: 50,
                      height: 50,
                      child: SvgPicture.asset('assets/icons/Ford-logo-flat.svg'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: ValueListenableBuilder(
                    valueListenable: services.hasInternet,
                    builder: (context, hasInternet, child) {
                      return SvgPicture.asset(
                        hasInternet
                            ? 'assets/material3icons/wifi.svg'
                            : 'assets/material3icons/wifi-off.svg',
                        color: constants.iconColor,
                        width: constants.iconSize,
                        height: constants.iconSize,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: SvgPicture.asset(
                    'assets/material3icons/bluetooth-disabled.svg',
                    color: constants.iconColor,
                    width: constants.iconSize,
                    height: constants.iconSize,
                  ),
                ),
                SvgPicture.asset(
                  'assets/material3icons/signal-cellular-off.svg',
                  color: constants.iconColor,
                  width: constants.iconSize,
                  height: constants.iconSize,
                ),
                DigitalClock(
                  digitalClockTextColor: constants.fontColor,
                  format: "HH:mm",
                  showSeconds: false,
                  isLive: true,
                ),
              ],
            ),
          ),
          Positioned(
            right: 10,
            top: 50,
            child: Column(
              children: [
                IconButton(
                  onPressed: toggleDarkmode,
                  icon: SvgPicture.asset(
                      color: constants.iconColor,
                      'assets/icons/theme-light-dark.svg'),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,

            left: 0,
            height: 635,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(
                  width: containerWidth,
                  color: constants.primaryColor,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,

            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(
                  width: screenSize.width,
                  height: 50,
                  color: constants.primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
