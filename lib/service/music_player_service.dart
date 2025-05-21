import 'package:audioplayers/audioplayers.dart';

class MusicPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playFromFileId(String fileId, {int? duration}) async {
    final proxyUrl = "http://localhost:3000/stream/$fileId";
    await _audioPlayer.play(UrlSource(proxyUrl));
    print("🎶 Playing music from: $proxyUrl (durasi: ${duration ?? '-'})");
  }

  Future<void> playFromUrl(String url, {int? duration}) async {
    await _audioPlayer.play(UrlSource(url));
    print("🎶 Playing from URL: $url (durasi: ${duration ?? '-'})");
  }

  Future<void> stopMusic() async {
    await _audioPlayer.stop();
    print("🛑 Music stopped.");
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
