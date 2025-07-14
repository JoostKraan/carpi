import 'dart:ui';
import 'package:app/widgets/clock.dart';
import 'package:app/widgets/music_player.dart';
import 'package:app/pages/settings.dart';
import 'package:app/providers/constants-provider.dart';
import 'package:app/providers/serial_provider.dart';
import 'package:app/providers/volume_provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:app/services/services.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/info_tab.dart';
import '../widgets/volume_slider.dart';

Services services = Services();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final constantsProvider = await ConstantsProvider.create();
  await dotenv.load(fileName: 'assets/.env');
  initialize();

  await FullScreen.ensureInitialized();
  if (dotenv.get("PLATFORM") == "pi") {
    FullScreen.setFullScreen(true);
  } else {
    FullScreen.setFullScreen(false);
  }


  final serialProvider = SerialReaderProvider();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => constantsProvider),
        ChangeNotifierProvider(create: (_) => VolumeProvider()),
        ChangeNotifierProvider.value(value: serialProvider),
      ],
      child: const MyApp(),
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
  final prefs = SharedPreferences.getInstance();
  bool showSettings = false;
  int _currentIndex = 0;
  final List<Widget> _carouselItems = [MusicPlayer(), carInfo()];

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double containerWidth = screenSize.width / 3;
    final constants = context.watch<ConstantsProvider>().constants;
    final volume = context.watch<VolumeProvider>().volume;
    final temp1 = context.watch<SerialReaderProvider>().temp1;
    final temp2 = context.watch<SerialReaderProvider>().temp2;
    final lat = context.watch<SerialReaderProvider>().lat;
    final lon = context.watch<SerialReaderProvider>().lon;
    final hasGps = context.watch<SerialReaderProvider>().hasLocation;

    return Scaffold(
      backgroundColor: constants.primaryColor,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            child: FlutterMap(
              children: [
                TileLayer(
                  retinaMode: true,
                  urlTemplate: constants.mapurl,
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    if (hasGps)
                      Marker(
                        point: LatLng(lat, lon),
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
                  child: IconButton(
                    onPressed: null,
                    icon: SvgPicture.asset(
                      'assets/icons/phone.svg',
                      color: constants.iconColor,
                      width: constants.iconSize,
                      height: constants.iconSize,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ValueListenableBuilder(
                    valueListenable: services.hasInternet,
                    builder: (context, hasInternet, child) {
                      return SvgPicture.asset(
                        hasInternet
                            ? 'assets/icons/wifi.svg'
                            : 'assets/icons/wifi-off.svg',
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
                    hasGps
                        ? 'assets/icons/location-on.svg'
                        : 'assets/icons/location-off.svg',
                    color: constants.iconColor,
                    width: constants.iconSize,
                    height: constants.iconSize,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: SvgPicture.asset(
                    'assets/icons/bluetooth-disabled.svg',
                    color: constants.iconColor,
                    width: constants.iconSize,
                    height: constants.iconSize,
                  ),
                ),
                SvgPicture.asset(
                  'assets/icons/signal-cellular-off.svg',
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
                    context.read<ConstantsProvider>().isDarkMode ?  'assets/icons/dark-mode.svg' :
                    'assets/icons/light-mode.svg',
                    width: constants.iconSize * 1,
                    height: constants.iconSize * 1,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            left: screenSize.width / 3 + 10,
            child: Row(
              children: [
                Text(
                  "$temp1°C",
                  style: TextStyle(
                    fontSize: constants.fontSize,
                    color: constants.fontColor,
                  ),
                ),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                padding: EdgeInsets.only(top: 10, bottom: 10),
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          style: TextStyle(
                                            fontSize: constants.fontSize * 2.5,
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
                                            fontSize: constants.fontSize * 0.8,
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
                                padding: EdgeInsets.only(top: 25, right: 30),
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
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: _carouselItems
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                          return Container(
                                            width: 8.0,
                                            height: 8.0,
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 4.0,
                                            ),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _currentIndex == entry.key
                                                  ? Colors.white
                                                  : Colors.white.withOpacity(
                                                      0.4,
                                                    ),
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
            right: 0,
            bottom: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(
                  height: 50,
                  color: constants.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                showSettings = !showSettings;
                              });
                            },
                            icon: SvgPicture.asset(
                              width: constants.iconSize,
                              height: constants.iconSize,
                              color: constants.iconColor,
                              'assets/icons/car-gear.svg',
                            ),
                          ),
                          Text(
                            "$temp2°C",
                            style: TextStyle(
                              fontSize: constants.fontSize,
                              color: constants.fontColor,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SvgPicture.asset(
                            volume == 0.0
                                ? 'assets/icons/volume_off.svg'
                                : volume < 10
                                ? 'assets/icons/volume_down.svg'
                                : 'assets/icons/volume_up.svg',
                            width: constants.iconSize,
                            height: constants.iconSize,
                            color: constants.iconColor,
                          ),
                          VolumeControl(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: screenSize.width / 3,
            height: screenSize.height - 100,
            width: screenSize.width,
            child: Container(child: showSettings ? Settings() : null),
          ),
        ],
      ),
    );
  }
}
