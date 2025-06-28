import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/constants-provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final constants = context.watch<ConstantsProvider>().constants;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Container(
          color: constants.primaryColor,
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20,left: 15),
                    child: Text(style: TextStyle(fontSize: constants.fontSize *1.2, color: constants.fontColor), "Settings"),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: constants.secondaryColor),
                        right: BorderSide(color: constants.secondaryColor),
                        bottom: BorderSide(color: constants.secondaryColor),
                        left: BorderSide.none,
                      ),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8.0),
                        bottomRight: Radius.circular(8.0),
                      ),
                    ),
                    width: screenSize.width/7,
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      "Appearance",
                      style: TextStyle(
                        fontSize: constants.fontSize,
                        color: constants.fontColor,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: constants.secondaryColor),
                        right: BorderSide(color: constants.secondaryColor),
                        bottom: BorderSide(color: constants.secondaryColor),
                        left: BorderSide.none,
                      ),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8.0),
                        bottomRight: Radius.circular(8.0),
                      ),
                    ),
                    width: screenSize.width/7,
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      "Appearance",
                      style: TextStyle(
                        fontSize: constants.fontSize,
                        color: constants.fontColor,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: constants.secondaryColor),
                        right: BorderSide(color: constants.secondaryColor),
                        bottom: BorderSide(color: constants.secondaryColor),
                        left: BorderSide.none,
                      ),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8.0),
                        bottomRight: Radius.circular(8.0),
                      ),
                    ),
                    width: screenSize.width/7,
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      "Appearance",
                      style: TextStyle(
                        fontSize: constants.fontSize,
                        color: constants.fontColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}