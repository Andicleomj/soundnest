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
  final DatabaseReference _musicRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/music/categories',
  );
  final DatabaseReference _murottalRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/murottal/categories',
  );

  final MusicPlayerService _playerService = MusicPlayerService();
  Timer? _timer;
  bool _isAudioPlaying = false;

  bool get isAudioPlaying => _isAudioPlaying;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => checkAndRunSchedule(),
    );

    _manualRef.onValue.listen((_) => checkAndRunSchedule());
    _autoRef.onValue.listen((_) => checkAndRunSchedule());
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
    await _manualRef.push().set({
      'time_start': time,
      'duration': duration,
      'category': category,
      'surah': surah,
      'day': day,
      'fileId': fileId,
      'isActive': true,
    });
    print("✅ Jadwal manual berhasil disimpan.");
  }

  Future<void> checkAndRunSchedule() async {
    if (_isAudioPlaying) return;

    print("⏰ Mengecek jadwal...");
    final now = DateTime.now();
    final schedules = await getSchedules();

    for (var schedule in schedules) {
      if ((schedule['isActive'] ?? false) && _isScheduleValid(schedule, now)) {
        await _runScheduledAudio(schedule);
        break;
      }
    }
  }

  Future<List<Map<String, dynamic>>> getSchedules() async {
    return [
      ...await _fetchSchedules(_manualRef),
      ...await _fetchSchedules(_autoRef),
    ];
  }

  Future<List<Map<String, dynamic>>> _fetchSchedules(
    DatabaseReference ref,
  ) async {
    try {
      final snapshot = await ref.get();
      if (snapshot.exists && snapshot.value != null) {
        final value = snapshot.value as Map;
        return value.values
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return [];
    } catch (e) {
      print("Error fetching schedules: $e");
      return [];
    }
  }

  bool _isScheduleValid(Map<String, dynamic> schedule, DateTime now) {
    try {
      final timeStart = schedule['time_start']?.toString();
      final day = schedule['day']?.toString();

      if (timeStart == null || day == null) return false;

      // More robust time parsing
      final parts = timeStart.split(':');
      if (parts.length != 2) return false;

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);

      if (hour == null || minute == null) return false;

      return hour == now.hour && minute == now.minute && _isToday(day);
    } catch (e) {
      print("Error validating schedule: $e");
      return false;
    }
  }

  bool _isToday(String day) {
    try {
      final today =
          [
            "Senin",
            "Selasa",
            "Rabu",
            "Kamis",
            "Jumat",
            "Sabtu",
            "Minggu",
          ][DateTime.now().weekday - 1];
      return day == today;
    } catch (e) {
      print("Error checking day: $e");
      return false;
    }
  }

  Future<void> _runScheduledAudio(Map<String, dynamic> schedule) async {
    try {
      final fileId = schedule['fileId']?.toString();
      final duration = schedule['duration']?.toString();

      if (fileId == null || fileId.isEmpty) return;

      final audioUrl = "http://localhost:3000/drive/$fileId";
      final durationMinutes = int.tryParse(duration ?? '1') ?? 1;

      print(
        "🔊 Memutar audio dari URL: $audioUrl selama $durationMinutes menit.",
      );
      _isAudioPlaying = true;

      await _playerService.playMusicFromProxy(audioUrl);
      await Future.delayed(Duration(minutes: durationMinutes));
    } catch (e) {
      print("Error running scheduled audio: $e");
    } finally {
      _isAudioPlaying = false;
    }
  }

  void dispose() {
    _timer?.cancel();
    _playerService.stopMusic();
    print("🛑 ScheduleService dihentikan.");
  }
}
