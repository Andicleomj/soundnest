import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class MusicPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  var currentTitle;

  var isPlayingNotifier;

  var pauseMusic;

  MusicPlayerService() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      print("🎧 Audio player state: $state");
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      print("✅ Playback selesai");
    });
  }

  /// Fungsi utilitas untuk dapatkan base URL sesuai platform
  String get _baseProxyUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000'; // untuk emulator Android
    } else {
      return 'http://localhost:3000';
    }
  }

  get currentCategoryNotifier => null;

  get currentTitleNotifier => null;

  /// Mainkan dari File ID melalui proxy backend
  Future<void> playFromFileId(String fileId) async {
    final proxyUrl = "$_baseProxyUrl/stream/$fileId";

    try {
      await _audioPlayer.setVolume(1.0); // Set volume maksimal
      await _audioPlayer.play(UrlSource(proxyUrl));
      print("🎶 Playing music from: $proxyUrl");
    } catch (e) {
      print("❌ Gagal memutar musik: $e");
    }
  }

  /// Mainkan langsung dari URL
  Future<void> playFromUrl(String url) async {
    try {
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play(UrlSource(url));
      print("🎶 Playing from URL: $url");
    } catch (e) {
      print("❌ Gagal memutar musik dari URL: $e");
    }
  }

  /// Hentikan musik
  Future<void> stopMusic() async {
    await _audioPlayer.stop();
    print("🛑 Music stopped.");
  }

  /// Hentikan dan dispose player
  void dispose() {
    _audioPlayer.dispose();
  }
}
