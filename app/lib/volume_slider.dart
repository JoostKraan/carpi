import 'package:app/providers/constants-provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volume_controller/volume_controller.dart';

class VolumeControl extends StatefulWidget {
  const VolumeControl({super.key});

  @override
  State<VolumeControl> createState() => _VolumeControlState();
}

class _VolumeControlState extends State<VolumeControl> {
  double _currentVolumeSlider = 10;  // 0–20 range

  @override
  void initState() {
    super.initState();
    VolumeController.instance.showSystemUI = true;

    // initialize from system:
    VolumeController.instance.getVolume().then((v) {
      setState(() {
        _currentVolumeSlider = v * 20;
      });
    });
    // listen for external changes (buttons, etc):
    VolumeController.instance.addListener((v) {
      setState(() {
        _currentVolumeSlider = v * 20;
      });
    }, fetchInitialVolume: false);
  }

  @override
  void dispose() {
    VolumeController.instance.removeListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final constants = context.watch<ConstantsProvider>().constants;

    return SizedBox(
      width: 200,
      height: 20,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 4,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        ),
        child: Slider(
          min: 0,
          max: 20,
          value: _currentVolumeSlider.clamp(0, 20),
          activeColor: constants.accentColor,
          inactiveColor: constants.primaryColor,
          onChanged: (v) {
            setState(() {
              _currentVolumeSlider = v;
            });
            final normalized = (v.clamp(0, 20)) / 20;
            VolumeController.instance.setVolume(normalized);
          },
        ),
      ),
    );
  }
}
