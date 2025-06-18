import 'dart:ui';
import 'package:app/clock.dart';
import 'package:app/music_player.dart';
import 'package:app/providers/constants-provider.dart';
import 'package:app/providers/volume_provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:app/services.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'package:provider/provider.dart';
import 'package:volume_controller/volume_controller.dart';
import 'esp32-data-reciever.dart';
import 'info_tab.dart';
import 'volume_slider.dart';

Services services = Services();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/.env');
  initialize();

  await FullScreen.ensureInitialized();
  if (dotenv.get("PLATFORM") == "pi") {
    FullScreen.setFullScreen(true);
  } else {
    FullScreen.setFullScreen(false);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConstantsProvider()),
        ChangeNotifierProvider(create: (_) => VolumeProvider()),
      ],
      child: const MyApp(),    // ← here’s the missing child
    ),
  );
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
  late SerialReader serialReader;
  int _currentIndex = 0;

  final List<Widget> _carouselItems = [MusicPlayer(), carInfo()];


  @override
  void initState() {
    super.initState();
    serialReader = SerialReader();
    serialReader.readData();

  }

  @override
  void dispose() {
    serialReader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double containerWidth = screenSize.width / 3;
    final constants = context.watch<ConstantsProvider>().constants;
    final vol = context.watch<VolumeProvider>().volume;  // 0.0–1.0
    final perc = (vol*100).round();

    // 0–100%

    return Scaffold(
      backgroundColor: constants.primaryColor,
      extendBodyBehindAppBar: true,
      body: StreamBuilder<String>(
        stream: serialReader.dataStream,
        builder: (context, snapshot) {
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
                    MarkerLayer(
                      markers: [
                        // if (data['lat'] != null && data['lng'] != null)
                        //    Marker(
                        //      // point: LatLng(
                        //      //   //data['lat'] as double,
                        //      //   //data['lng'] as double,
                        //      // ),
                        //      width: 50,
                        //      height: 50,
                        //      child: SvgPicture.asset(
                        //        'assets/icons/Ford-logo-flat.svg',
                        //      ),
                        //    ),
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
                      onPressed: () =>
                          context.read<ConstantsProvider>().toggleDarkMode(),
                      icon: SvgPicture.asset(
                        color: constants.iconColor,
                        'assets/icons/theme-light-dark.svg',
                        width: constants.iconSize * 1.5,
                        height: constants.iconSize * 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 40,
                right: 35,
                child: VolumeControl(),

              ),



              Positioned(
                top: 5,
                left: screenSize.width / 3 + 10,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: SvgPicture.asset(
                        width: constants.iconSize / 1.5,
                        height: constants.iconSize / 1.5,
                        color: constants.iconColor,
                        'assets/icons/pine-tree-variant.svg',
                      ),
                    ),
                    // Text(
                    //   style: TextStyle(
                    //     fontSize: constants.fontSize,
                    //     color: constants.fontColor,
                    //   ),
                    //   //"${(data['temp1'] ?? 0).toStringAsFixed(0)}°C",
                    // ),
                  ],
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
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: constants.secondaryColor,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      alignment: AlignmentGeometry.center,
                                      height: 35,
                                      width: 90,
                                      child: Text(
                                        style: TextStyle(
                                          fontSize: constants.fontSize,
                                          color: constants.fontColor,
                                        ),
                                        "500km",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Spacer(),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: 10,
                                      bottom: 10,
                                      right: 30,
                                    ),
                                    child: SvgPicture.asset(
                                      color: constants.errorColor,
                                      width: constants.iconSize * 1.5,
                                      height: constants.iconSize * 1.5,
                                      'assets/icons/car-brake-parking.svg',
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: 10,
                                      bottom: 10,
                                      right: 30,
                                    ),
                                    child: SvgPicture.asset(
                                      color: constants.errorColor,
                                      width: constants.iconSize * 1.5,
                                      height: constants.iconSize * 1.5,
                                      'assets/icons/hazard-lights.svg',
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: 10,
                                      bottom: 10,
                                    ),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 25,
                                      left: 30,
                                    ),
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
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    height: 100,
                                    width: containerWidth / 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    constants.fontSize * 2.5,
                                                color: constants.fontColor,
                                              ),
                                              "0",
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    constants.fontSize * 0.8,
                                                color: constants.fontColor
                                                    .withOpacity(0.4),
                                              ),
                                              "km/h",
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: 25,
                                      right: 30,
                                    ),
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
                                    padding: const EdgeInsets.only(top: 20),
                                    child: SvgPicture.asset(
                                      color: constants.iconColor,
                                      width: containerWidth / 1.5,
                                      height: containerWidth / 1.5,
                                      'assets/img/Escort_top.svg',
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: screenSize.height / 5,
                                          width: screenSize.width / 3,
                                          child: CarouselSlider(
                                            items: _carouselItems,
                                            options: CarouselOptions(
                                              viewportFraction: 1.0,
                                              enlargeCenterPage: false,
                                              enableInfiniteScroll: false,
                                              onPageChanged: (index, reason) {
                                                setState(() {
                                                  _currentIndex = index;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: _carouselItems
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                              return Container(
                                                width: 8.0,
                                                height: 8.0,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 4.0,
                                                    ),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color:
                                                      _currentIndex == entry.key
                                                      ? Colors.white
                                                      : Colors.white
                                                            .withOpacity(0.4),
                                                ),
                                              );
                                            })
                                            .toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
                          SvgPicture.asset(
                            color: constants.iconColor,
                            width: constants.iconSize / 1.5,
                            height: constants.iconSize / 1.5,
                            'assets/icons/car.svg',
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.only(left: 10, right: 5),
                          //   child: Text(
                          //     //"${(data['temp2'] ?? 0).toStringAsFixed(0)}°C",
                          //     style: TextStyle(
                          //       fontSize: constants.fontSize,
                          //       color: constants.fontColor,
                          //     ),
                          //   ),
                          // ),
                          IconButton(
                            onPressed: null,
                            icon: SvgPicture.asset(
                              width: constants.iconSize * 1.3,
                              height: constants.iconSize * 1.3,
                              'assets/icons/fan-off.svg',
                              color: constants.iconColor,
                            ),
                          ),
                          IconButton(
                            onPressed: null,
                            icon: SvgPicture.asset(
                              width: constants.iconSize * 1.3,
                              height: constants.iconSize * 1.3,
                              'assets/icons/knob.svg',
                              color: constants.iconColor,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 1),
                            child: Text(
                              style: TextStyle(
                                fontSize: constants.fontSize,
                                color: constants.iconColor,
                              ),
                              "30%",
                            ),
                          ),
                          Spacer(),
                          const SizedBox(width: 60),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: IconButton(
                              onPressed: () {
                                // toggle between mute and full volume
                                if (vol == 0) {
                                  context.read<VolumeProvider>().volume = 1.0;
                                } else {
                                  context.read<VolumeProvider>().volume = 0.0;
                                }
                              },
                              icon: SvgPicture.asset(
                                vol <= 0
                                    ? 'assets/material3icons/volume_off.svg'
                                    : vol < 0.5
                                    ? 'assets/material3icons/volume_down.svg'
                                    : 'assets/material3icons/volume_up.svg',
                                width: constants.iconSize * 1.3,
                                height: constants.iconSize * 1.3,
                                color: constants.iconColor,
                              ),
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
