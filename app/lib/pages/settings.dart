import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/constants-provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _settingsState();
}

class _settingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    final constants = context.watch<ConstantsProvider>().constants;
    final Size screenSize = MediaQuery.of(context).size;
    return Container(
        color: constants.primaryColor,
        child: ListView(
          children: [
            ListTile()
          ],
        )
    );
  }
}
