import 'dart:async';
import 'dart:ui';
import 'package:app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:app/services.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'esp32-data-reciever.dart';

Services services = Services();
late WebSocketService ws;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/.env');
  ws = WebSocketService();
  initialize();

  await FullScreen.ensureInitialized();
  if (dotenv.get("PLATFORM") == "pi") {
    FullScreen.setFullScreen(true);
  } else {
    FullScreen.setFullScreen(false);
  }

  runApp(const MyApp());
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
        dividerTheme: const DividerThemeData(color: Colors.transparent),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

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
    final constants = Constants(darkmode);

    return Scaffold(
      backgroundColor: constants.primaryColor,
      extendBodyBehindAppBar: true,
      body: StreamBuilder(
        stream: ws.stream,
        builder: (context, snapshot) {
          final data = snapshot.hasData
              ? snapshot.data as Map<String, dynamic>
              : {'lat': null, 'lng': null, 'temp1': 0.0, 'temp2': 0.0};
          return Stack(
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
                        backgroundColor: const Color(0x00ffffff),
                        source: Text(
                          'OpenStreetMap contributors',
                          style: TextStyle(color: constants.iconColor),
                        ),
                      ),
                    ),
                    MarkerLayer(
                      markers: [
                        if (data['lat'] != null && data['lng'] != null)
                          Marker(
                            point: LatLng(
                              data['lat'] as double,
                              data['lng'] as double,
                            ),
                            width: 50,
                            height: 50,
                            child: SvgPicture.asset(
                              'assets/icons/Ford-logo-flat.svg',
                            ),
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
                      padding: const EdgeInsets.only(right: 10),
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
                      padding: const EdgeInsets.only(right: 10),
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
                    ClockWidget(color: constants.fontColor),
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
                        'assets/icons/theme-light-dark.svg',
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 5,
                left: screenSize.width / 3 + 10,
                child: Text(
                  style: TextStyle(
                    fontSize: constants.fontSize,
                    color: constants.fontColor,
                  ),
                  "${(data['temp1'] ?? 0).toStringAsFixed(0)}°C",
                ),
              ),
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    child: Container(
                      width: containerWidth,
                      color: constants.primaryColor,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Spacer(),
                              Padding(
                                padding: EdgeInsets.only(top: 10,bottom: 10,right: 30),
                                child: SvgPicture.asset(
                                  color: constants.errorColor,
                                  width: constants.iconSize * 1.5,
                                  height: constants.iconSize * 1.5,
                                  'assets/icons/car-brake-parking.svg',
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 10,bottom: 10,right: 30),
                                child: SvgPicture.asset(
                                  color: constants.errorColor,
                                  width: constants.iconSize * 1.5,
                                  height: constants.iconSize * 1.5,
                                  'assets/icons/hazard-lights.svg',
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: SvgPicture.asset(
                                  color: constants.accentColor,
                                  width: constants.iconSize * 1.5,
                                  height: constants.iconSize * 1.5,
                                  'assets/icons/car-light-dimmed.svg',
                                ),
                              ),
                              Spacer(),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 25,left: 30),
                                child: SvgPicture.asset(
                                  color: constants.successColor,
                                  width: constants.iconSize * 1.5,
                                  height: constants.iconSize * 1.5,
                                  'assets/icons/arrow-left-bold-outline.svg',
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: constants.secondaryColor,
                                  ),
                                  borderRadius: BorderRadius.circular(15)
                                ),
                                height: 100,
                                width: containerWidth / 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(style: TextStyle(fontSize: constants.fontSize*2.5, color: constants.fontColor), "0"),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(style: TextStyle(fontSize: constants.fontSize*0.8, color: constants.fontColor.withOpacity(0.4)), "km/h"),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 25,right: 30),
                                child: SvgPicture.asset(
                                  color: constants.successColor,
                                  width: constants.iconSize * 1.5,
                                  height: constants.iconSize * 1.5,
                                  'assets/icons/arrow-right-bold-outline.svg',
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 50),
                                child: SvgPicture.asset(color: Colors.white60, width: containerWidth/1.5,height: containerWidth/1.5,'assets/img/Escort_top.svg'),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: screenSize.width / 3,
                bottom: 0,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    child: Container(
                      width: screenSize.width * 2 / 3,
                      height: 50,
                      color: constants.primaryColor,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 5),
                            child: Text(
                              "${(data['temp2'] ?? 0).toStringAsFixed(0)}°C",
                              style: TextStyle(
                                fontSize: constants.fontSize,
                                color: constants.fontColor,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: null,
                            icon: SvgPicture.asset(
                              'assets/icons/fan-off.svg',
                              color: constants.iconColor,
                            ),
                          ),
                          IconButton(
                            onPressed: null,
                            icon: SvgPicture.asset(
                              'assets/icons/knob.svg',
                              color: constants.iconColor,
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                "MediaPlayer",
                                style: TextStyle(color: constants.fontColor),
                              ),
                            ),
                          ),
                          const SizedBox(width: 60),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: SvgPicture.asset(
                              'assets/icons/volume-mute.svg',
                              color: constants.iconColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ClockWidget extends StatefulWidget {
  final Color color;

  const ClockWidget({super.key, required this.color});

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  late DateTime now;
  late final Timer timer;

  @override
  void initState() {
    super.initState();
    now = DateTime.now();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formatted =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 20),
      child: Text(
        formatted,
        style: TextStyle(
          fontSize: 18,
          color: widget.color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
