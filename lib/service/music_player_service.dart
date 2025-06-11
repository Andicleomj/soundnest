import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:soundnest/utils/volume_helper.dart';

typedef VoidCallback = void Function();

class MusicPlayerService {
  static final MusicPlayerService _instance = MusicPlayerService._internal();

  factory MusicPlayerService() {
    return _instance;
  }

  MusicPlayerService._internal() {
    // Listen state player dan update isPlaying serta notifiers
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      final playing = state == PlayerState.playing;
      if (isPlaying != playing) {
        isPlaying = playing;
        isPlayingNotifier.value = isPlaying;
      }
      print("🎧 Audio player state: $state");
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      print("✅ Playback selesai");
      _clearCurrentMusic();
      _onComplete?.call();
    });
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
final AudioPlayer _alarmPlayer = AudioPlayer(); 

  // Informasi state musik
  bool isPlaying = false;
  String? currentFileId;

  // Notifier untuk UI binding
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier(false);
  final ValueNotifier<String?> currentTitleNotifier = ValueNotifier(null);
  final ValueNotifier<String?> currentCategoryNotifier = ValueNotifier(null);

  VoidCallback? _onComplete;

  String get _baseProxyUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else if (Platform.isAndroid) {
      return 'http://192.168.0.102:3000';
    } else {
      return 'http://localhost:3000';
    }
  }

  Future<void> playFromFileId(
    String fileId, {
    String? title,
    String? category,
  }) async {
    final proxyUrl = "$_baseProxyUrl/stream/$fileId";

    if (isPlaying) {
      await stopMusic(); // ini menghentikan musik apa pun yang sedang jalan
    }

    try {
      final volume = await VolumeHelper.getVolume(); // <== Ambil volume
      await _audioPlayer.setVolume(volume); // <== Terapkan volume
      await _audioPlayer.play(UrlSource(proxyUrl));

      currentFileId = fileId;
      isPlaying = true;
      isPlayingNotifier.value = true;

      currentTitleNotifier.value = title;
      currentCategoryNotifier.value = category;

      print("🎶 Playing music from: $proxyUrl at volume: ${volume * 100}%");
    } catch (e) {
      print("❌ Gagal memutar musik: $e");
    }
  }

  Future<void> playFromUrl(String url) async {
    try {
      final volume = await VolumeHelper.getVolume(); // <== Ambil volume
      await _audioPlayer.setVolume(volume); // <== Terapkan volume
      await _audioPlayer.play(UrlSource(url));

      currentFileId = url;
      isPlaying = true;
      isPlayingNotifier.value = true;

      print("🎶 Playing from URL: $url at volume: ${volume * 100}%");
    } catch (e) {
      print("❌ Gagal memutar musik dari URL: $e");
    }
  }


  Future<void> pauseMusic() async {
    if (!isPlaying) return; // Jika sudah pause, skip

    await _audioPlayer.pause();
    isPlaying = false;
    isPlayingNotifier.value = false;
    print("⏸️ Music paused.");
  }

  Future<void> resumeMusic() async {
    if (isPlaying) return; // Jika sudah play, skip

    await _audioPlayer.resume();
    isPlaying = true;
    isPlayingNotifier.value = true;
    print("▶️ Music resumed.");
  }

  Future<void> stopMusic() async {
    await _audioPlayer.stop();
    _clearCurrentMusic();
    print("🛑 Music stopped.");
  }

  void _clearCurrentMusic() {
    isPlaying = false;
    isPlayingNotifier.value = false;

    currentFileId = null;
    currentTitleNotifier.value = null;
    currentCategoryNotifier.value = null;
  }

  void setOnCompleteListener(VoidCallback callback) {
    _onComplete = callback;
  }

  void dispose() {
    _audioPlayer.dispose();
    print("🗑️ AudioPlayer disposed.");
  }

  // Getter untuk akses dari luar
  String? get currentTitle => currentTitleNotifier.value;
  String? get currentCategory => currentCategoryNotifier.value;

  void addListener(void Function() audioStatusListener) {}

  void removeListener(void Function() audioStatusListener) {}
}
