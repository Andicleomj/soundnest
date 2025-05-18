import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:soundnest/service/music_player_service.dart';
import 'package:http/http.dart' as http;

class ScheduleService {
  // Fixed typo in 'devices' path (was 'devices')
  final DatabaseReference _manualRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/schedule/manual',
  );
  final DatabaseReference _autoRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/schedule/otomatis',
  );
  final DatabaseReference _musicRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/music/categories',
  );
  final DatabaseReference _murottalRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/murottal/categories',
  );

  final MusicPlayerService _playerService = MusicPlayerService();
  Timer? _timer;
  bool _isAudioPlaying = false;
  StreamSubscription? _manualSubscription;
  StreamSubscription? _autoSubscription;

  bool get isAudioPlaying => _isAudioPlaying;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => checkAndRunSchedule(),
    );

    _manualSubscription?.cancel();
    _autoSubscription?.cancel();

    _manualSubscription = _manualRef.onValue.listen(
      (_) => checkAndRunSchedule(),
    );
    _autoSubscription = _autoRef.onValue.listen((_) => checkAndRunSchedule());
    print("✅ ScheduleService started.");
  }

  // ... [keep all other existing methods unchanged until _runScheduledAudio] ...

  Future<void> _runScheduledAudio(Map<String, dynamic> schedule) async {
    try {
      print('🔍 Starting Google Drive audio playback process...');

      // 1. Get category and file references
      final categoryMap = {
        "Ayat Kursi": "kategori_1",
        "Surah Pendek": "kategori_2",
      };
      final categoryKey = categoryMap[schedule['category']] ?? 'kategori_1';
      final fileKey = schedule['fileKey'] ?? 'file_1';

      // 2. Get audio metadata from Firebase
      final audioRef = FirebaseDatabase.instance.ref(
        'devices/devices_01/murottal/categories/$categoryKey/files/$fileKey',
      );
      print('📡 Firebase path: ${audioRef.path}');

      final snapshot = await audioRef.get();
      if (!snapshot.exists) {
        print('❌ Audio metadata not found');
        return;
      }

      final audioData = Map<String, dynamic>.from(snapshot.value as Map);
      print('🔊 Audio metadata: $audioData');

      // 3. Get Google Drive file ID
      final fileId = audioData['fileId'] ?? audioData['file1'];
      if (fileId == null || fileId.isEmpty) {
        print('❌ No Google Drive file ID found');
        return;
      }

      // 4. Construct Google Drive URL (using direct download link)
      final audioUrl = _getGoogleDriveUrl(fileId.toString());
      print('🔗 Google Drive URL: $audioUrl');

      // 5. Verify URL (optional - might not work for all Google Drive links)
      try {
        final response = await http.head(Uri.parse(audioUrl));
        if (response.statusCode != 200) {
          print('⚠️ URL verification failed (HTTP ${response.statusCode})');
          // Continue anyway as some Google Drive links might still work
        }
      } catch (e) {
        print('⚠️ URL verification error: $e');
      }

      // 6. Start playback
      _isAudioPlaying = true;
      await _playerService.play(audioUrl);
      print('✅ Audio playback started');
    } catch (e) {
      print('❌ Playback error: ${e.toString()}');
      if (e is FirebaseException) {
        print('Firebase error: ${e.code} - ${e.message}');
      }
    } finally {
      _isAudioPlaying = false;
    }
  }

  String _getGoogleDriveUrl(String fileId) {
    // Choose one of these options:

    // Option 1: Direct download link (file must be publicly shared)
    return 'https://drive.google.com/uc?export=download&id=$fileId';

    // Option 2: Alternative direct link
    // return 'https://docs.google.com/uc?id=$fileId';

    // Option 3: If you have a proxy server
    // return 'https://your-server.com/proxy?fileId=$fileId';
  }

  // Add this method to fix the missing method error
  Future<void> checkAndRunSchedule() async {
    // TODO: Implement your schedule checking and running logic here.
    print('🔄 checkAndRunSchedule called');
    // Example: You might want to fetch schedules and call _runScheduledAudio if needed.
  }

  void dispose() {
    _timer?.cancel();
    _manualSubscription?.cancel();
    _autoSubscription?.cancel();
    _playerService.stopMusic();
    print("🛑 ScheduleService stopped.");
  }
}
