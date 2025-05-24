import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

typedef VoidCallback = void Function();

class MusicPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  VoidCallback? _onComplete;
  String? currentFileId;
  bool isPlaying = false;

  // ✅ Notifier untuk UI (mini player)
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier(false);
  final ValueNotifier<String?> currentTitleNotifier = ValueNotifier(null);
  final ValueNotifier<String?> currentCategoryNotifier = ValueNotifier(null);

  MusicPlayerService() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      print("🎧 Audio player state: $state");
      isPlaying = state == PlayerState.playing;
      isPlayingNotifier.value = isPlaying; // 🔔 Update UI state
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      print("✅ Playback selesai");
      isPlaying = false;
      isPlayingNotifier.value = false;
      currentFileId = null;
      currentTitleNotifier.value = null;
      currentCategoryNotifier.value = null;
      _onComplete?.call();
    });
  }

  String get _baseProxyUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    } else {
      return 'http://localhost:3000';
    }
  }

  /// ✅ Mainkan musik dan update informasi judul dan kategori
  Future<void> playFromFileId(
    String fileId, {
    String? title,
    String? category,
  }) async {
    final proxyUrl = "$_baseProxyUrl/stream/$fileId";

    if (isPlaying) {
      await stopMusic(); // <-- ganti pauseMusic dengan stopMusic
    }

    try {
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play(UrlSource(proxyUrl));

      currentFileId = fileId;
      isPlaying = true;
      isPlayingNotifier.value = true;

      currentTitleNotifier.value = title;
      currentCategoryNotifier.value = category;

      print("🎶 Playing music from: $proxyUrl");
    } catch (e) {
      print("❌ Gagal memutar musik: $e");
    }
  }

  Future<void> playFromUrl(String url) async {
    try {
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play(UrlSource(url));

      currentFileId = url;
      isPlaying = true;
      isPlayingNotifier.value = true;

      print("🎶 Playing from URL: $url");
    } catch (e) {
      print("❌ Gagal memutar musik dari URL: $e");
    }
  }

  Future<void> pauseMusic() async {
    await _audioPlayer.pause();
    isPlaying = false;
    isPlayingNotifier.value = false;
    print("⏸️ Music paused.");
  }

  Future<void> resumeMusic() async {
    await _audioPlayer.resume();
    isPlaying = true;
    isPlayingNotifier.value = true;
    print("▶️ Music resumed.");
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
    print("🔊 Volume set to: $volume");
  }

  Future<void> stopMusic() async {
    await _audioPlayer.stop();
    isPlaying = false;
    isPlayingNotifier.value = false;

    currentFileId = null;
    currentTitleNotifier.value = null;
    currentCategoryNotifier.value = null;

    print("🛑 Music stopped.");
  }

  void setOnCompleteListener(VoidCallback callback) {
    _onComplete = callback;
  }

  void dispose() {
    _audioPlayer.dispose();
    print("🗑️ AudioPlayer disposed.");
  }

  /// ✅ Getter bantuan untuk dibaca dari luar
  String? get currentTitle => currentTitleNotifier.value;
  String? get currentCategory => currentCategoryNotifier.value;
}
