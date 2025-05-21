import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:soundnest/service/music_player_service.dart';

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

  /// ✅ Perbaikan: Mapping field agar sesuai dengan Firebase
  Future<List<Map<String, dynamic>>> getSchedules() async {
    final snapshot = await _manualRef.get();
    if (!snapshot.exists) return [];

    final data = (snapshot.value as Map).entries.toList();
    return data.map((entry) {
      final schedule = Map<String, dynamic>.from(entry.value);

      final dayList = schedule['hari'];
      final firstDay = dayList is Map ? dayList.values.first : null;

      return {
        'fileId': schedule['file_id'],
        'duration': schedule['durasi']?.toString(),
        'isActive': schedule['enabled'] == true,
        'time_start': schedule['waktu'],
        'day': firstDay,
      };
    }).toList();
  }

  /// ✅ Parsing waktu dari string format 12 jam seperti "9:38 PM"
  bool _isScheduleValid(Map<String, dynamic> schedule, DateTime now) {
    final timeStart = schedule['time_start'];
    final day = schedule['day'];

    if (timeStart == null || day == null) return false;

    final scheduleTime = _parseTimeOfDay(timeStart);
    final nowTime = TimeOfDay(hour: now.hour, minute: now.minute);

    return scheduleTime.hour == nowTime.hour &&
        scheduleTime.minute == nowTime.minute &&
        _isToday(day);
  }

  /// ✅ Fungsi bantu untuk parsing jam AM/PM
  TimeOfDay _parseTimeOfDay(String time) {
    final regex = RegExp(r'^(\d+):(\d+)\s*(AM|PM)$', caseSensitive: false);
    final match = regex.firstMatch(time.trim());

    if (match == null) return const TimeOfDay(hour: 0, minute: 0);

    int hour = int.parse(match.group(1)!);
    int minute = int.parse(match.group(2)!);
    final period = match.group(3)!.toUpperCase();

    if (period == 'PM' && hour < 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;

    return TimeOfDay(hour: hour, minute: minute);
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

    final duration = int.tryParse(schedule['duration'] ?? '1') ?? 1;
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
