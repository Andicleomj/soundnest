import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

typedef VoidCallback = void Function();

class MusicPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  VoidCallback? _onComplete;
  String? currentFileId;
  bool isPlaying = false;

  MusicPlayerService() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      print("🎧 Audio player state: $state");
      isPlaying = state == PlayerState.playing;
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      print("✅ Playback selesai");
      isPlaying = false;
      currentFileId = null;
      _onComplete?.call();
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

  /// Mainkan dari File ID melalui proxy backend
  Future<void> playFromFileId(String fileId) async {
    final proxyUrl = "$_baseProxyUrl/stream/$fileId";

    try {
      await _audioPlayer.setVolume(1.0); // Set volume maksimal
      await _audioPlayer.play(UrlSource(proxyUrl));
      currentFileId = fileId;
      isPlaying = true;
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
      currentFileId = url;
      isPlaying = true;
      print("🎶 Playing from URL: $url");
    } catch (e) {
      print("❌ Gagal memutar musik dari URL: $e");
    }
  }

  /// Jeda musik
  Future<void> pauseMusic() async {
    await _audioPlayer.pause();
    isPlaying = false;
    print("⏸️ Music paused.");
  }

  /// Lanjutkan musik
  Future<void> resumeMusic() async {
    await _audioPlayer.resume();
    isPlaying = true;
    print("▶️ Music resumed.");
  }

  /// Setel volume
  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume); // 0.0 - 1.0
    print("🔊 Volume set to: $volume");
  }

  /// Hentikan musik
  Future<void> stopMusic() async {
    await _audioPlayer.stop();
    isPlaying = false;
    currentFileId = null;
    print("🛑 Music stopped.");
  }

  /// Pasang listener ketika musik selesai
  void setOnCompleteListener(VoidCallback callback) {
    _onComplete = callback;
  }

  /// Dispose audio player
  void dispose() {
    _audioPlayer.dispose();
    print("🗑️ AudioPlayer disposed.");
  }
}
