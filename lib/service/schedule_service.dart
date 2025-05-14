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
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => checkAndRunSchedule(),
    );
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
    print("⏰ Mengecek jadwal...");
    final now = DateTime.now();
    final schedules = await getSchedules();
    print("📅 Jumlah jadwal ditemukan: ${schedules.length}");

    for (var schedule in schedules) {
      if (!(schedule['isActive'] ?? false)) continue;
      if (!_isScheduleValid(schedule, now)) continue;

      await _runScheduledAudio(schedule);
      print("✅ Audio dijalankan.");
    }
  }

  Future<void> _runScheduledAudio(Map<String, dynamic> schedule) async {
    final fileId = schedule['file_id'];
    if (fileId == null) return;

    final proxyUrl = "http://localhost:3000/stream/$fileId";
    print("🔗 URL: $proxyUrl");

    _isAudioPlaying = true;
    await _playerService.playMusicFromProxy(fileId);
    _isAudioPlaying = false;

    print("🎶 Audio dimainkan sesuai jadwal: ${schedule['time_start']}.");
  }

  bool _isScheduleValid(Map<String, dynamic> schedule, DateTime now) {
    final day = schedule['day']?.toLowerCase();
    final timeStart = schedule['time_start'];

    if (day == null || timeStart == null) return false;
    if (day != _getDayOfWeek(now)) return false;

    final parts = timeStart.split(':');
    if (parts.length != 2) return false;

    return now.hour == int.parse(parts[0]) && now.minute == int.parse(parts[1]);
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
