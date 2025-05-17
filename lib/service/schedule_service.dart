import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:soundnest/service/music_player_service.dart';
import 'package:audioplayers/audioplayers.dart';

class ScheduleService {
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

  Future<void> saveManualSchedule(
    String time,
    String duration,
    String category,
    String surah,
    String day,
    String
    fileId, // This should be the full reference like "kategori_1/files/file_1"
  ) async {
    await _manualRef.push().set({
      'time_start': time,
      'duration': duration,
      'category': category,
      'surah': surah,
      'day': day,
      'fileId': fileId, // Store complete path
      'fileKey': "file_1", // Store the actual file key
      'isActive': true,
      'createdAt': ServerValue.timestamp,
    });
  }

  Future<void> checkAndRunSchedule() async {
    if (_isAudioPlaying) {
      print("⏯ Audio already playing, skipping check");
      return;
    }

    print("⏰ Checking schedules...");
    final now = DateTime.now();
    final schedules = await getSchedules();

    for (var schedule in schedules) {
      try {
        if ((schedule['isActive'] ?? false) &&
            _isScheduleValid(schedule, now)) {
          print("🎯 Found matching schedule: ${schedule['surah']}");
          await _runScheduledAudio(schedule);
          break;
        }
      } catch (e) {
        print("⚠️ Error processing schedule: $e");
      }
    }
  }

  Future<List<Map<String, dynamic>>> getSchedules() async {
    try {
      final manual = await _fetchSchedules(_manualRef);
      final auto = await _fetchSchedules(_autoRef);
      return [...manual, ...auto]..sort((a, b) {
        final timeA = a['time_start'] ?? '';
        final timeB = b['time_start'] ?? '';
        return timeA.compareTo(timeB);
      });
    } catch (e) {
      print("❌ Error getting schedules: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchSchedules(
    DatabaseReference ref,
  ) async {
    try {
      final snapshot = await ref.get();
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return data.entries.map<Map<String, dynamic>>((entry) {
          return {
            'key': entry.key,
            ...(entry.value is Map
                ? Map<String, dynamic>.from(entry.value as Map)
                : {}),
          };
        }).toList();
      }
      return [];
    } catch (e) {
      print("❌ Error fetching schedules: $e");
      return [];
    }
  }

  bool _isScheduleValid(Map<String, dynamic> schedule, DateTime now) {
    try {
      final timeStart = schedule['time_start']?.toString();
      final day = schedule['day']?.toString();

      if (timeStart == null || day == null) return false;

      final parts = timeStart.split(':');
      if (parts.length != 2) return false;

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);

      if (hour == null || minute == null) return false;

      return hour == now.hour && minute == now.minute && _isToday(day);
    } catch (e) {
      print("❌ Error validating schedule: $e");
      return false;
    }
  }

  bool _isToday(String day) {
    try {
      final days = [
        "Senin",
        "Selasa",
        "Rabu",
        "Kamis",
        "Jumat",
        "Sabtu",
        "Minggu",
      ];
      return day == days[DateTime.now().weekday - 1];
    } catch (e) {
      print("❌ Error checking day: $e");
      return false;
    }
  }

  Future<void> _runScheduledAudio(Map<String, dynamic> schedule) async {
    try {
      final category = schedule['category']?.toString() ?? 'kategori_1';
      final fileKey = schedule['fileKey']?.toString() ?? 'file_1';

      // Construct the correct Firebase reference
      final audioRef = FirebaseDatabase.instance.ref(
        'devices/devices_01/murottal/categories/$category/files/$fileKey',
      );

      final snapshot = await audioRef.get();
      if (!snapshot.exists) {
        print('❌ Audio file not found at ${audioRef.path}');
        return;
      }

      final audioData = Map<String, dynamic>.from(snapshot.value as Map);
      final fileId = audioData['file1']?.toString(); // Get the actual file ID

      if (fileId == null || fileId.isEmpty) {
        print('❌ No fileId found in audio data');
        return;
      }

      // Use your actual audio URL pattern
      final audioUrl = "https://your-audio-server.com/$fileId";

      print('🔊 Playing audio from $audioUrl');
      _isAudioPlaying = true;
      await _playerService.play(audioUrl);

      // ... rest of your playback logic
    } catch (e) {
      print('❌ Error playing scheduled audio: $e');
    } finally {
      _isAudioPlaying = false;
    }
  }

  void dispose() {
    _timer?.cancel();
    _manualSubscription?.cancel();
    _autoSubscription?.cancel();
    _playerService.dispose();
    print("🛑 ScheduleService stopped");
  }
}
