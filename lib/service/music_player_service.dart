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

    // Listen untuk posisi dan durasi
    _audioPlayer.onPositionChanged.listen((Duration position) {
      currentPositionNotifier.value = position;
    });

    _audioPlayer.onDurationChanged.listen((Duration duration) {
      durationNotifier.value = duration;
    });
  }

  final AudioPlayer _audioPlayer = AudioPlayer();

  // Informasi state musik
  bool isPlaying = false;
  String? currentFileId;

  // Notifier untuk UI binding
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> currentTitleNotifier = ValueNotifier(null);
  final ValueNotifier<String?> currentCategoryNotifier = ValueNotifier(null);
  final ValueNotifier<Duration> currentPositionNotifier = ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> durationNotifier = ValueNotifier(Duration.zero);

  VoidCallback? _onComplete;

  String get _serverUrl {
    return 'http://31.97.109.216:4500';
  }

  Future<void> playFromFileId(
    String fileId, {
    String? title,
    String? category,
    VoidCallback? onComplete,
  }) async {
    final server = "$_serverUrl/stream/$fileId";

    if (isPlaying) {
      await stopMusic(); // Ini menghentikan musik apa pun yang sedang jalan
    }

    try {
      final volume = await VolumeHelper.getVolume(); // <== Ambil volume
      await _audioPlayer.setVolume(volume); // <== Terapkan volume
      await _audioPlayer.play(UrlSource(server));

      currentFileId = fileId;
      isPlaying = true;
      isPlayingNotifier.value = true;

      currentTitleNotifier.value = title;
      currentCategoryNotifier.value = category;

      _onComplete = onComplete;

      print("🎶 Playing music from: $server at volume: ${volume * 100}%");
    } catch (e) {
      print("❌ Gagal memutar musik: $e");
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

  Future<void> seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      currentPositionNotifier.value = position; // Sinkronkan posisi
      print("⏩ Seeking to: ${position.inSeconds} seconds");
    } catch (e) {
      print("❌ Gagal seek: $e");
    }
  }

  void _clearCurrentMusic() {
    isPlaying = false;
    isPlayingNotifier.value = false;

    currentFileId = null;
    currentTitleNotifier.value = null;
    currentCategoryNotifier.value = null;
    currentPositionNotifier.value = Duration.zero;
    durationNotifier.value = Duration.zero;
  }

  Future<void> pauseForAlarm() async {
    try {
      await _audioPlayer.pause();
      if (_audioPlayer.state == PlayerState.playing) {
        // Tidak bisa pause, fallback ke stop
        print("⚠ Pause gagal di alarm, fallback stop");
        await stopMusic();
      } else {
        isPlaying = false;
        isPlayingNotifier.value = false;
      }
    } catch (e) {
      print("❌ Gagal pause untuk alarm: $e");
    }
  }

  void setOnCompleteListener(VoidCallback callback) {
    _onComplete = callback;
  }

  void dispose() {
    _audioPlayer.dispose();
    isPlayingNotifier.dispose();
    currentTitleNotifier.dispose();
    currentCategoryNotifier.dispose();
    currentPositionNotifier.dispose();
    durationNotifier.dispose();
    print("🗑️ AudioPlayer disposed.");
  }

  // Getter untuk akses dari luar
  String? get currentTitle => currentTitleNotifier.value;
  String? get currentCategory => currentCategoryNotifier.value;
  Duration get currentPosition => currentPositionNotifier.value;
  Duration get duration => durationNotifier.value;

  void addListener(void Function() audioStatusListener) {
    // Implementasi opsional jika diperlukan
  }

  void removeListener(void Function() audioStatusListener) {
    // Implementasi opsional jika diperlukan
  }
}
