import 'package:just_audio/just_audio.dart';

class AlarmAudioController {
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool get isPlaying => _audioPlayer.playing;

  Future<void> setUrl(String url) async {
    await _audioPlayer.setUrl(url, preload: true);
  }

  Future<void> play() => _audioPlayer.play();

  Future<void> pause() => _audioPlayer.pause();

  Future<void> stop() => _audioPlayer.stop();

  Future<void> seekToStart() => _audioPlayer.seek(Duration.zero);

  void dispose() {
    _audioPlayer.dispose();
  }
}
