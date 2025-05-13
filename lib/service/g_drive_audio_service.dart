import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;

class GoogleDriveAudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Fungsi untuk memutar audio dari Google Drive menggunakan file ID
  Future<void> playFromGoogleDrive(String fileId) async {
    final url = _getGoogleDriveUrl(fileId);
    print("🔗 Mencoba memutar audio dari URL: $url");

    try {
      if (await _validateUrl(url)) {
        if (_audioPlayer.playing) await _audioPlayer.stop();
        await _audioPlayer.setUrl(url);
        await _audioPlayer.play();
        print("🎵 Memutar audio dari Google Drive: $url");
      } else {
        print("❌ URL tidak valid atau tidak dapat diakses.");
      }
    } catch (e) {
      print("❌ Gagal memutar audio dari Google Drive: $e");
    }
  }

  // Fungsi untuk mengecek URL Google Drive
  Future<bool> _validateUrl(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // Fungsi untuk mendapatkan URL download Google Drive
  String _getGoogleDriveUrl(String fileId) {
    return "https://drive.google.com/uc?export=download&id=$fileId";
  }

  // Fungsi untuk menghentikan audio
  Future<void> stopAudio() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.stop();
      print("🛑 Audio dihentikan.");
    }
  }

  // Getter untuk mengecek status audio
  bool get isPlaying => _audioPlayer.playing;

  // Fungsi untuk dispose audio player
  void dispose() {
    _audioPlayer.dispose();
    print("♻️ Audio Player di-dispose.");
  }
}
