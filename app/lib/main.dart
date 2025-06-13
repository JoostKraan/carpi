import 'package:app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:app/services.dart';
import 'package:one_clock/one_clock.dart';
import 'package:blur/blur.dart';

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

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),fontFamily: 'Manrope'
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

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double containerWidth = screenSize.width / 3;

    return Scaffold(
        extendBodyBehindAppBar: true,
      appBar: PreferredSize(

        preferredSize: Size.fromHeight(50.0),
        child: AppBar(
          elevation: 0,
          backgroundColor: Constants.primaryColor,
          flexibleSpace: Stack(
            children: [
              Blur(
                blur: 2,
                blurColor: Constants.primaryColor,
                child: Container(color: Constants.primaryColor.withOpacity(0.01)),
              ),
            ],
          ),

          title: Row(
            children: [
              Text("47L",style: TextStyle(color: Constants.fontColor,fontSize:  Constants.textSize)),

            ],
          ),

          actions: [
            Padding(padding: EdgeInsets.only(right: 10),
              child: ValueListenableBuilder(valueListenable: services.hasInternet, builder: (context,hasInternet,child){
                return SvgPicture.asset(hasInternet ? 'assets/icons/wifi.svg' : 'assets/icons/wifi-off.svg',
                    color: Constants.iconColor,
                    width: Constants.iconSize,
                    height: Constants.iconSize);
              }
              )
            ),
            Padding(padding: EdgeInsets.only(right: 10),
              child:SvgPicture.asset('assets/icons/bluetooth.svg',
                color: Constants.iconColor,
                width: Constants.iconSize,
                height: Constants.iconSize,
              ),
            ),
            Padding(padding: EdgeInsets.only(right: 10),
              child:SvgPicture.asset('assets/icons/satellite-variant.svg',
                color: Constants.iconColor,
                width: Constants.iconSize,
                height: Constants.iconSize,
              ),
            ),
            Padding(padding: EdgeInsets.only(right: 10),
              child: DigitalClock(
                digitalClockTextColor: Constants.fontColor,

                  format: "HH:mm",
                  showSeconds: false,
                  isLive:true,),
            ),
          ],
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: FlutterMap(
            options: MapOptions(
              initialCenter: const LatLng(1, 1),
              initialZoom: 3.2,
            ),
            children: [
              TileLayer(
                retinaMode: true,
                urlTemplate: 'https://tile.jawg.io/jawg-light/{z}/{x}/{y}{r}.png?access-token=ME95gmQBq6fVpZys7OtD6VJLMx706vzQRALB4oZiea5VnbQ7rfH9xjiOIu5wyy5b',
                userAgentPackageName: 'com.example.app',
                ),
              ],
            ),
          ),
          Positioned(top: 50,
              left: 0,
              width: containerWidth,
              height: screenSize.height,
              child: SizedBox(
                child:
              Blur(
                blurColor: Constants.primaryColor,
                blur: 2,
                child: Container(
                  color: Constants.primaryColor,
                  child: Text("Test"),
                  ),
              ),
              )
          )

        ]
      )
    );
  }
}
