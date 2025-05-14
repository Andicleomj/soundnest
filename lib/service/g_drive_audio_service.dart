import 'package:audioplayers/audioplayers.dart';

class GoogleDriveAudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playFromUrl(String url) async {
    print("🎶 Memutar audio dari URL langsung: $url");
    try {
      await _audioPlayer.play(UrlSource(url));
      print("✅ Audio dari URL langsung dimainkan.");
    } catch (e) {
      print("❌ Gagal memutar audio: $e");
    }
  }

  void dispose() {
    _audioPlayer.dispose();
    print("🔴 GoogleDriveAudioService dihentikan.");
  }
}
