import 'package:cast/device.dart';
import 'package:soundnest/service/cast_service.dart';
import 'package:soundnest/service/music_player_service.dart';

class AudioControllerService {
  final CastService _castService;
  final MusicPlayerService _musicPlayerService;

  CastDevice? selectedDevice;

  AudioControllerService(this._castService, this._musicPlayerService);

  Future<void> playAudio({
    required String fileId,
    required String title,
    bool toGoogleCast = false,
  }) async {
    final url = "http://172.20.10.7:3000/stream/$fileId";

    if (toGoogleCast) {
      if (selectedDevice == null) throw Exception("Belum memilih perangkat cast");
      await _castService.connectToDevice(selectedDevice!);
      await _castService.playMedia(url, title: title);
    } else {
      await _musicPlayerService.playFromUrl(url);  // Sesuai dengan method di MusicPlayerService
    }
  }

  Future<void> pauseAudio({bool onCast = false}) async {
    if (onCast) {
      await _castService.pause();
    } else {
      await _musicPlayerService.pauseMusic();  // Sesuaikan nama method
    }
  }

  Future<void> stopAudio({bool onCast = false}) async {
    if (onCast) {
      await _castService.stop();
    } else {
      await _musicPlayerService.stopMusic();  // Sesuaikan nama method
    }
  }
}
