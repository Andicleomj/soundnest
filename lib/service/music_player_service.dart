import 'package:audioplayers/audioplayers.dart';

class MusicPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playMusicFromProxy(String fileId) async {
    final proxyUrl = "http://localhost:3000/stream/$fileId";
    await _audioPlayer.play(UrlSource(proxyUrl));
    print("🎶 Playing music from: $proxyUrl");
  }

  Future<void> play(String fileId, {int? duration}) async {
    final proxyUrl = "http://localhost:3000/stream/$fileId";
    await _audioPlayer.play(UrlSource(proxyUrl));
    print(
      "🎶 Playing music from: $proxyUrl (durasi: ${duration ?? '-'} menit)",
    );
  }

  Future<void> stopMusic() async {
    await _audioPlayer.stop();
    print("🛑 Music stopped.");
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
