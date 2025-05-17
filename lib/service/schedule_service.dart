import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:soundnest/service/music_player_service.dart';

class ScheduleService {
  final DatabaseReference _manualRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/schedule/manual',
  );
  final DatabaseReference _autoRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/schedule/otomatis',
  );
  final DatabaseReference _murottalRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/murottal/categories',
  );

  final MusicPlayerService _playerService = MusicPlayerService();
  Timer? _timer;
  bool _isAudioPlaying = false;
  StreamSubscription<DatabaseEvent>? _manualSubscription;
  StreamSubscription<DatabaseEvent>? _autoSubscription;

  bool get isAudioPlaying => _isAudioPlaying;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => checkAndRunSchedule(),
    );

    _manualSubscription?.cancel();
    _autoSubscription?.cancel();

    _manualSubscription = _manualRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        checkAndRunSchedule();
      }
    });

    _autoSubscription = _autoRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        checkAndRunSchedule();
      }
    });

    print("✅ ScheduleService started.");
  }

  Future<void> saveManualSchedule(
    String time,
    String duration,
    String category,
    String surah,
    String day,
    String fileReference,
  ) async {
    try {
      // Validate inputs
      if (time.isEmpty ||
          duration.isEmpty ||
          category.isEmpty ||
          surah.isEmpty ||
          day.isEmpty ||
          fileReference.isEmpty) {
        throw Exception("All schedule fields must be filled");
      }

      if (!RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(time)) {
        throw Exception("Invalid time format. Use HH:MM");
      }

      if (int.tryParse(duration) == null || int.parse(duration) <= 0) {
        throw Exception("Duration must be a positive number");
      }

      final fileKey = fileReference.split('/').last;

      await _manualRef.push().set({
        'time_start': time,
        'duration': duration,
        'category': category,
        'surah': surah,
        'day': day,
        'fileReference': fileReference,
        'fileKey': fileKey,
        'isActive': true,
        'createdAt': ServerValue.timestamp,
      });

      print("✅ Schedule saved for $surah at $time");
    } catch (e) {
      print("❌ Error saving schedule: $e");
      rethrow;
    }
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
                : <String, dynamic>{}),
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
      final categoryMap = {
        "Ayat Kursi": "kategori_1",
        "Surah Pendek": "kategori_2",
      };

      final categoryKey = categoryMap[schedule['category']] ?? 'kategori_1';
      final fileKey = schedule['fileKey'] ?? 'file_1';

      final audioRef = _murottalRef.child('$categoryKey/files/$fileKey');
      final snapshot = await audioRef.get();

      if (!snapshot.exists) {
        print('❌ Audio metadata not found at ${audioRef.path}');
        return;
      }

      final audioData = Map<String, dynamic>.from(snapshot.value as Map);
      final fileId = audioData['file1']?.toString();

      if (fileId == null || fileId.isEmpty) {
        print('❌ No fileId found in audio data');
        return;
      }

      final audioUrl = "https://your-storage.com/audios/$fileId.mp3";
      print('🔊 Playing audio from: $audioUrl');

      _isAudioPlaying = true;
      await _playerService.play(audioUrl);

      final durationMinutes = int.tryParse(schedule['duration'] ?? '1') ?? 1;
      final stopwatch = Stopwatch()..start();

      while (stopwatch.elapsed.inMinutes < durationMinutes && _isAudioPlaying) {
        await Future.delayed(const Duration(seconds: 10));
      }
    } catch (e) {
      print('❌ Error playing audio: $e');
    } finally {
      _isAudioPlaying = false;
      print("⏹ Finished audio playback");
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
