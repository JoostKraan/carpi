import 'package:app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:app/services.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';
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

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: AppBar(
          backgroundColor: Constants.primaryColor,
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
      body: Row(
        children: [
          Column(
            children: [
              SizedBox( height: 600,width: 1000, child: Container(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: const LatLng(1, 1),
                    initialZoom: 3.2,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                  ],
                ),
              ),)
            ],
          )
        ],
      )
    );
  }
}
