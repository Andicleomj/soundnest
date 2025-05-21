import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class MusicPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _stopTimer;

  MusicPlayerService() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      print("🎧 Audio player state: $state");
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      print("✅ Playback selesai");
    });

    // Error listener removed: onPlayerError is not available in the current AudioPlayer API.
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
  Future<void> playFromFileId(String fileId, {int? duration}) async {
    final proxyUrl = "$_baseProxyUrl/stream/$fileId";

    try {
      await _audioPlayer.setVolume(1.0); // Set volume maksimal
      await _audioPlayer.play(UrlSource(proxyUrl));
      print("🎶 Playing music from: $proxyUrl (durasi: ${duration ?? '-'})");

      // Hentikan jika ada durasi
      _stopTimer?.cancel();
      if (duration != null && duration > 0) {
        _stopTimer = Timer(Duration(minutes: duration), () async {
          await stopMusic();
          print("🛑 Music auto-stopped after $duration minutes");
        });
      }
    } catch (e) {
      print("❌ Gagal memutar musik: $e");
    }
  }

  /// Mainkan langsung dari URL
  Future<void> playFromUrl(String url, {int? duration}) async {
    try {
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play(UrlSource(url));
      print("🎶 Playing from URL: $url (durasi: ${duration ?? '-'})");

      _stopTimer?.cancel();
      if (duration != null && duration > 0) {
        _stopTimer = Timer(Duration(minutes: duration), () async {
          await stopMusic();
          print("🛑 Music auto-stopped after $duration minutes");
        });
      }
    } catch (e) {
      print("❌ Gagal memutar musik dari URL: $e");
    }
  }

  /// Hentikan musik
  Future<void> stopMusic() async {
    _stopTimer?.cancel();
    await _audioPlayer.stop();
    print("🛑 Music stopped.");
  }

  /// Hentikan dan dispose player
  void dispose() {
    _stopTimer?.cancel();
    _audioPlayer.dispose();
  }
}
