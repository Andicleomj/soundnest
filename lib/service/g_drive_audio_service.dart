import 'package:audioplayers/audioplayers.dart';

class GoogleDriveAudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playFromGoogleDrive(String fileId) async {
    final url = 'https://drive.google.com/uc?export=download&id=$fileId';
    print("🔗 Memutar audio dari Google Drive dengan ID: $fileId");
    print("🔗 URL: $url");

    try {
      // Memutar audio dari URL (tanpa result)
      await _audioPlayer.play(UrlSource(url));
      print("✅ Audio dimainkan dari URL: $url");
    } catch (e) {
      print("❌ Error saat memutar audio: $e");
    }
  }

  void dispose() {
    _audioPlayer.dispose();
    print("🛑 GoogleDriveAudioService dihentikan.");
  }
}
