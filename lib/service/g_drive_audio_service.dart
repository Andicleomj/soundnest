import 'package:just_audio/just_audio.dart';

class GoogleDriveAudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Fungsi untuk memutar audio dari Google Drive menggunakan file ID
  Future<void> playFromGoogleDrive(String fileId) async {
    try {
      final url = "https://drive.google.com/uc?export=download&id=$fileId";
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
      print("🎵 Memutar audio dari Google Drive: $url");
    } catch (e) {
      print("❌ Gagal memutar audio dari Google Drive: $e");
    }
  }

  // Fungsi untuk menghentikan audio
  Future<void> stopAudio() async {
    await _audioPlayer.stop();
  }

  // Fungsi untuk dispose audio player
  void dispose() {
    _audioPlayer.dispose();
  }
}
