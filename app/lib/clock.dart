import 'dart:async';

import 'package:flutter/material.dart';

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
