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

  Future<void> checkAndRunSchedule() async {
    if (_isAudioPlaying) return;

    print("⏰ Checking schedules...");
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
    final snapshot = await _manualRef.get();
    if (!snapshot.exists) return [];

    final data = (snapshot.value as Map).values.toList();
    return data.cast<Map<String, dynamic>>();
  }

  bool _isScheduleValid(Map<String, dynamic> schedule, DateTime now) {
    final timeStart = schedule['time_start'];
    final day = schedule['day'];

    if (timeStart == null || day == null) return false;

    final parts = timeStart.split(':');
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    return hour == now.hour && minute == now.minute && _isToday(day);
  }

  bool _isToday(String day) {
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
  }

  Future<void> _runScheduledAudio(Map<String, dynamic> schedule) async {
    final audioUrl = "http://localhost:3000/drive/${schedule['fileId']}";

    _isAudioPlaying = true;
    await _playerService.play(audioUrl);

    final duration = int.tryParse(schedule['duration']) ?? 1;
    await Future.delayed(Duration(minutes: duration));

    _playerService.stopMusic();
    _isAudioPlaying = false;
  }

  void dispose() {
    _timer?.cancel();
    _playerService.stopMusic();
    print("🛑 ScheduleService stopped.");
  }
}
