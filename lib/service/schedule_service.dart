import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:soundnest/service/music_service.dart';
import 'package:soundnest/service/music_player_service.dart';

class ScheduleService {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref(
    'devices/devices_01/schedule_001',
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

  Future<List<Map<String, dynamic>>> getSchedules() async {
    try {
      final snapshot = await _ref.get();
      if (snapshot.exists && snapshot.value is Map) {
        return (snapshot.value as Map).values
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (e) {
      print("❌ Error fetching schedules: $e");
    }
    return [];
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

    final fileId = schedule['file_id'];
    if (fileId == null) return;

    final proxyUrl = "http://localhost:3000/stream/$fileId";
    print("🔗 URL: $proxyUrl");

    try {
      _isAudioPlaying = true;
      await _playerService.playMusicFromProxy(fileId);
      print("🎶 Audio dimainkan sesuai jadwal: ${schedule['time_start']}.");
    } catch (e) {
      print("❌ Error saat memutar audio: $e");
    } finally {
      _isAudioPlaying = false;
    }
  }

  bool _isScheduleValid(Map<String, dynamic> schedule, DateTime now) {
    final day = schedule['day']?.toString().toLowerCase();
    final timeStart = schedule['time_start']?.toString();

    if (day == null || timeStart == null) return false;
    if (day != _getDayOfWeek(now)) return false;

    final parts = timeStart.split(':');
    if (parts.length != 2) return false;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return false;

    return now.hour == hour && now.minute == minute;
  }

  String _getDayOfWeek(DateTime now) {
    const days = [
      'senin',
      'selasa',
      'rabu',
      'kamis',
      'jumat',
      'sabtu',
      'minggu',
    ];
    return days[now.weekday - 1];
  }

  void dispose() {
    _timer?.cancel();
    _playerService.stopMusic();
    print("🛑 ScheduleService dihentikan.");
  }
}
