import 'package:just_audio/just_audio.dart';

class AlarmAudioController {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isReady = false;

  /// Mengecek apakah sedang memutar
  bool get isPlaying => _audioPlayer.playing;

  /// Menyiapkan URL audio dan preload
  Future<void> setUrl(String url) async {
    try {
      await _audioPlayer.setUrl(url, preload: true);
      _isReady = true;
    } catch (e) {
      print("⚠ Gagal set URL audio: $e");
      _isReady = false;
    }
  }

  /// Memutar audio jika sudah siap
  Future<void> play() async {
    if (_isReady && !_audioPlayer.playing) {
      try {
        await _audioPlayer.play();
        print("▶️ Audio diputar");
      } catch (e) {
        print("⚠ Gagal memutar audio: $e");
      }
    }
  }

  /// Menjeda audio
  Future<void> pause() async {
    if (_audioPlayer.playing) {
      try {
        await _audioPlayer.pause();
        print("⏸ Audio dijeda");
      } catch (e) {
        print("⚠ Gagal menjeda audio: $e");
      }
    }
  }

  /// Menghentikan dan reset ke awal
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      await seekToStart();
      print("⏹ Audio dihentikan");
    } catch (e) {
      print("⚠ Gagal menghentikan audio: $e");
    }
  }

  /// Reset audio ke awal
  Future<void> seekToStart() async {
    try {
      await _audioPlayer.seek(Duration.zero);
    } catch (e) {
      print("⚠ Gagal seek ke awal: $e");
    }
  }

  /// Dispose audio player saat tidak digunakan
  void dispose() {
    _audioPlayer.dispose();
    print("🧹 Audio player disposed");
  }
}
