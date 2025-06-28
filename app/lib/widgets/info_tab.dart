import 'package:app/providers/constants-provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class carInfo extends StatefulWidget {
  const carInfo({super.key});

  @override
  State<carInfo> createState() => _carInfoState();

}

class _carInfoState extends State<carInfo> {
  late final constants = context.watch<ConstantsProvider>().constants;
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: constants.secondaryColor),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      height: screenSize.height / 5,
      width: screenSize.width / 4,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  style: TextStyle(color: constants.fontColor),
                  "Current trip",
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("100", style: TextStyle(color: constants.fontColor)),
                    SizedBox(height: 4),
                    Text("km", style: TextStyle(color: constants.fontColor.withOpacity(0.5))),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("0", style: TextStyle(color: constants.fontColor)),
                    SizedBox(height: 4),
                    Text("L", style: TextStyle(color: constants.fontColor.withOpacity(0.5))),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Text("0", style: TextStyle(color: constants.fontColor)),
                    SizedBox(height: 4),
                    Text("L/100Km", style: TextStyle(color: constants.fontColor.withOpacity(0.5))),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("00:00:00", style: TextStyle(color: constants.fontColor)),
                    SizedBox(height: 4),
                    Text("Duration", style: TextStyle(color: constants.fontColor.withOpacity(0.5))),
                  ],
                ),
              ],
            ),
          )

        ],
      ),
    );
  }
}
