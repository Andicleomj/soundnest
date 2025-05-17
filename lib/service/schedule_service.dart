import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:soundnest/service/music_service.dart';
import 'package:soundnest/service/music_player_service.dart';

class ScheduleService {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref(
    'devices/devices_01/schedule_001',
  );
  final DatabaseReference _manualRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/schedule/manual',
  );
  final DatabaseReference _autoRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/schedule/otomatis',
  );
  final DatabaseReference _musicRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/music/categories',
  );
  final MusicService _musicService = MusicService();
  final MusicPlayerService _playerService = MusicPlayerService();

  Timer? _timer;
  bool _isAudioPlaying = false;

  bool get isAudioPlaying => _isAudioPlaying;

  void start() {
    _timer?.cancel();
    _ref.onValue.listen((event) {
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
  ) async {
    try {
      await _manualRef.push().set({
        'time_start': time,
        'duration': duration,
        'category': category,
        'isActive': true,
      });
      print("✅ Jadwal manual berhasil disimpan.");
    } catch (e) {
      print("❌ Gagal menyimpan jadwal manual: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getSchedules() async {
    List<Map<String, dynamic>> schedules = [];

    try {
      final manualSnapshot = await _manualRef.get();
      if (manualSnapshot.exists && manualSnapshot.value is Map) {
        schedules.addAll(
          (manualSnapshot.value as Map).values
              .map((e) => Map<String, dynamic>.from(e))
              .toList(),
        );
      }

      final autoSnapshot = await _autoRef.get();
      if (autoSnapshot.exists && autoSnapshot.value is Map) {
        schedules.addAll(
          (autoSnapshot.value as Map).values
              .map((e) => Map<String, dynamic>.from(e))
              .toList(),
        );
      }
    } catch (e) {
      print("❌ Error fetching schedules: $e");
    }

    return schedules;
  }

  Future<void> checkAndRunSchedule() async {
    if (_isAudioPlaying) return;

    print("⏰ Mengecek jadwal...");
    final now = DateTime.now();
    final schedules = await getSchedules();

    for (var schedule in schedules) {
      if (!(schedule['isActive'] ?? false)) continue;
      if (!_isScheduleValid(schedule, now)) continue;

      await _runScheduledAudio(schedule);
    }
  }

  Future<void> _runScheduledAudio(Map<String, dynamic> schedule) async {
    if (_isAudioPlaying) return;

    final category = schedule['category'];
    final duration = schedule['duration'];

    if (category == null) return;

    print("🔊 Memutar audio kategori: $category selama $duration menit.");

    try {
      _isAudioPlaying = true;
      await _playerService.playMusicFromProxy(category);
      await Future.delayed(Duration(minutes: int.parse(duration)));
    } catch (e) {
      print("❌ Error saat memutar audio: $e");
    } finally {
      _isAudioPlaying = false;
    }
  }

  bool _isScheduleValid(Map<String, dynamic> schedule, DateTime now) {
    final timeStart = schedule['time_start']?.toString();
    if (timeStart == null) return false;

    final parts = timeStart.split(':');
    if (parts.length != 2) return false;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return false;

    return now.hour == hour && now.minute == minute;
  }

  void dispose() {
    _timer?.cancel();
    _playerService.stopMusic();
    print("🛑 ScheduleService dihentikan.");
  }
}
