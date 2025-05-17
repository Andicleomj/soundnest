import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:soundnest/service/music_player_service.dart';
import 'package:http/http.dart' as http;

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

    // Cancel previous subscriptions to avoid duplicates
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
    String fileId,
  ) async {
    try {
      // Validate inputs before saving
      if (time.isEmpty ||
          duration.isEmpty ||
          category.isEmpty ||
          surah.isEmpty ||
          day.isEmpty ||
          fileId.isEmpty) {
        throw Exception("All schedule fields must be filled");
      }

      // Validate time format (HH:MM)
      if (!RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(time)) {
        throw Exception("Invalid time format. Use HH:MM");
      }

      // Validate duration is a positive number
      if (int.tryParse(duration) == null || int.parse(duration) <= 0) {
        throw Exception("Duration must be a positive number");
      }

      await _manualRef.push().set({
        'time_start': time,
        'duration': duration,
        'category': category,
        'surah': surah,
        'day': day,
        'fileId': fileId,
        'isActive': true,
        'createdAt': ServerValue.timestamp,
      });
      print("✅ Manual schedule saved: $surah at $time on $day");
    } catch (e) {
      print("❌ Error saving manual schedule: $e");
      rethrow;
    }
  }

  Future<void> checkAndRunSchedule() async {
    if (_isAudioPlaying) {
      print("⏯ Audio is already playing, skipping schedule check");
      return;
    }

    print("⏰ Checking schedules...");
    final now = DateTime.now();
    final schedules = await getSchedules();

    for (var schedule in schedules) {
      try {
        if ((schedule['isActive'] ?? false) &&
            _isScheduleValid(schedule, now)) {
          print(
            "🎯 Found matching schedule: ${schedule['surah']} at ${schedule['time_start']}",
          );
          await _runScheduledAudio(schedule);
          break; // Only run one schedule at a time
        }
      } catch (e) {
        print("⚠️ Error processing schedule: $e");
      }
    }
  }

  Future<List<Map<String, dynamic>>> getSchedules() async {
    try {
      final manualSchedules = await _fetchSchedules(_manualRef);
      final autoSchedules = await _fetchSchedules(_autoRef);

      // Combine and sort by time_start (optional)
      return [...manualSchedules, ...autoSchedules]..sort((a, b) {
        final timeA = a['time_start']?.toString() ?? '';
        final timeB = b['time_start']?.toString() ?? '';
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
          final value = entry.value;
          return {
            'key': entry.key,
            ...(value is Map ? Map<String, dynamic>.from(value as Map) : {}),
          };
        }).toList();
      }
      return [];
    } catch (e) {
      print("❌ Error fetching schedules from ${ref.path}: $e");
      return [];
    }
  }

  bool _isScheduleValid(Map<String, dynamic> schedule, DateTime now) {
    try {
      final timeStart = schedule['time_start']?.toString();
      final day = schedule['day']?.toString();

      if (timeStart == null || day == null) {
        print("⚠️ Schedule missing time_start or day");
        return false;
      }

      final parts = timeStart.split(':');
      if (parts.length != 2) {
        print("⚠️ Invalid time format: $timeStart");
        return false;
      }

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);

      if (hour == null || minute == null) {
        print("⚠️ Invalid hour or minute in time: $timeStart");
        return false;
      }

      final isTimeMatch = hour == now.hour && minute == now.minute;
      final isDayMatch = _isToday(day);

      if (isTimeMatch && isDayMatch) {
        print("✅ Schedule matches current time: $timeStart $day");
      } else {
        print(
          "⏱ Schedule doesn't match (Current: ${now.hour}:${now.minute} $day)",
        );
      }

      return isTimeMatch && isDayMatch;
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
      final today = days[DateTime.now().weekday - 1];
      return day == today;
    } catch (e) {
      print("❌ Error checking day: $e");
      return false;
    }
  }

  Future<void> _runScheduledAudio(Map<String, dynamic> schedule) async {
    try {
      final categoryMap = {
        "Ayat Kursi": "kategori_1",
        "Surah Pendek": "kategori_2",
      };
      final categoryKey = categoryMap[schedule['category']] ?? 'kategori_1';
      final fileKey = schedule['fileKey'] ?? 'file_1';

      // 1. Get the actual file ID from Firebase
      final audioRef = FirebaseDatabase.instance.ref(
        'devices/devices_01/murottal/categories/$categoryKey/files/$fileKey',
      );
      final snapshot = await audioRef.get();

      if (!snapshot.exists) {
        print('❌ Audio metadata not found');
        return;
      }

      final audioData = Map<String, dynamic>.from(snapshot.value as Map);
      final fileId = audioData['file1']?.toString();

      if (fileId == null || fileId.isEmpty) {
        print('❌ No fileId found in audio data');
        return;
      }

      // 2. Construct PROPER audio URL (no spaces, no double processing)
      final encodedFileId = Uri.encodeComponent(fileId);
      final audioUrl = "http://localhost:3000/drive/$encodedFileId";

      print('🔊 Attempting to play: $audioUrl');

      // 3. Verify URL before playing
      final response = await http.head(Uri.parse(audioUrl));
      if (response.statusCode != 200) {
        print('❌ Audio file not available (HTTP ${response.statusCode})');
        return;
      }

      _isAudioPlaying = true;
      await _playerService.play(audioUrl);

      // ... rest of playback logic ...
    } catch (e) {
      print('❌ Playback error: $e');
    } finally {
      _isAudioPlaying = false;
    }
  }

  void dispose() {
    _timer?.cancel();
    _manualSubscription?.cancel();
    _autoSubscription?.cancel();
    _playerService.stopMusic();
    print("🛑 ScheduleService stopped.");
  }
}
