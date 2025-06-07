import 'package:cast/device.dart';
import 'package:soundnest/service/cast_service.dart';
import 'package:soundnest/service/music_player_service.dart';

class AudioControllerService {
  final CastService _castService;
  final MusicPlayerService _musicPlayerService;

  CastDevice? selectedDevice;
  bool _isCasting = false;

  AudioControllerService(this._castService, this._musicPlayerService);
  bool get isCasting => _isCasting;

  Future<void> playAudio({
    required String fileId,
    required String title,
    bool toGoogleCast = false,
  }) async {
    final url = "http://172.20.10.7:3000/stream/$fileId";

    if (toGoogleCast) {
      if (selectedDevice == null)
        throw Exception("Belum memilih perangkat cast");
      await _castService.connectToDevice(selectedDevice!);
      await _castService.playMedia(url, title: title);
      _isCasting = true;
    } else {
      await _musicPlayerService.playFromUrl(url);
      _isCasting = false;
    }
  }

  Future<void> pauseAudio() async {
    if (_isCasting) {
      await _castService.pause();
    } else {
      await _musicPlayerService.pauseMusic();
    }
  }

  Future<void> stopAudio() async {
    if (_isCasting) {
      await _castService.stop();
    } else {
      await _musicPlayerService.stopMusic();
    }
  }

  Future<void> toggleOutput({
    required bool toCast,
    required String fileId,
    required String title,
  }) async {
    if (toCast && !_isCasting) {
      await stopAudio();
      await playAudio(fileId: fileId, title: title, toGoogleCast: true);
    } else if (!toCast && _isCasting) {
      await stopAudio();
      await playAudio(fileId: fileId, title: title, toGoogleCast: false);
    }
  }
}
