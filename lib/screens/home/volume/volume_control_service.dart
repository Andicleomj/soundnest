// lib/service/volume_control_service.dart
import 'package:volume_controller/volume_controller.dart';
import 'package:soundnest/utils/volume_helper.dart';

Future<void> initVolumeControl() async {
  final savedVolume = await VolumeHelper.getVolume();

  VolumeController().showSystemUI = false;

  VolumeController().listener((volume) {
    if ((volume - savedVolume).abs() > 0.01) {
      VolumeController().setVolume(savedVolume);
    }
  });

  VolumeController().setVolume(savedVolume);
}
