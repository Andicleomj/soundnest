import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
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

    _ref.onValue.listen((event) => checkAndRunSchedule());
    print("✅ ScheduleService started.");
  }

  Future<void> checkAndRunSchedule() async {
    if (_isAudioPlaying) return;

    print("⏰ Mengecek jadwal...");
    final now = DateTime.now();
    final schedules = await getSchedules();

    for (var schedule in schedules) {
      if ((schedule['isActive'] ?? false) && _isScheduleValid(schedule, now)) {
        await _runScheduledAudio(schedule);
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
      if (snapshot.exists) {
        return (snapshot.value as Map).entries
            .map((e) => {...Map<String, dynamic>.from(e.value), 'id': e.key})
            .toList();
      }
    } catch (e) {
      print("❌ Error fetching schedules: $e");
    }
    return [];
  }

  bool _isScheduleValid(Map<String, dynamic> schedule, DateTime now) {
    final timeStart = schedule['time_start'];
    final day = schedule['day'];

    if (timeStart == null || day == null) return false;

    final parts = timeStart.split(':');
    if (parts.length != 2) return false;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    return hour == now.hour && minute == now.minute && _isToday(day);
  }

  bool _isToday(String day) {
    final today =
        [
          'Senin',
          'Selasa',
          'Rabu',
          'Kamis',
          'Jumat',
          'Sabtu',
          'Minggu',
        ][DateTime.now().weekday - 1];
    return day == today;
  }

  Future<void> _runScheduledAudio(Map<String, dynamic> schedule) async {
    if (_isAudioPlaying) return;

    final audioUrl = schedule['audio_url'];
    if (audioUrl == null) return;

    print("🔊 Memutar audio dari URL: $audioUrl.");
    _isAudioPlaying = true;

    try {
      await _playerService.playMusicFromProxy(audioUrl);
      await Future.delayed(
        Duration(minutes: int.tryParse(schedule['duration']) ?? 1),
      );
    } finally {
      _isAudioPlaying = false;
    }
  }

  Future<void> saveManualSchedule(
    String time,
    String duration,
    String category,
    String day,
    String audioUrl,
  ) async {
    await _manualRef.push().set({
      'time_start': time,
      'duration': duration,
      'category': category,
      'day': day,
      'audio_url': audioUrl,
      'isActive': true,
    });
    print("✅ Jadwal manual berhasil disimpan.");
  }

  void dispose() {
    _timer?.cancel();
    _playerService.stopMusic();
    print("🛑 ScheduleService dihentikan.");
  }
}
