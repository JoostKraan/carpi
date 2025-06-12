import 'package:app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MyApp());
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
          title: Text("100%",style: TextStyle(color: Constants.fontColor,fontSize:  Constants.textSize)),
          leading: SvgPicture.asset('assets/icons/fuel.svg',
            color: Constants.fontColor,
          ),
          leadingWidth: 30,
        
          actions: [
            Padding(padding: EdgeInsets.only(right: 10),
              child:SvgPicture.asset('assets/icons/wifi.svg',
              color: Constants.iconColor,
              width: Constants.iconSize,
              height: Constants.iconSize,
              ),
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
              child: Text("Time",style: TextStyle(color: Constants.fontColor,fontSize: Constants.textSize),)
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
