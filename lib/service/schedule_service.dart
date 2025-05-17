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
  final DatabaseReference _murottalRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/murottal/categories',
  );

  final MusicService _musicService = MusicService();
  final MusicPlayerService _playerService = MusicPlayerService();

  Timer? _timer;
  bool _isAudioPlaying = false;

  bool get isAudioPlaying => _isAudioPlaying;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => checkAndRunSchedule(),
    );

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
    String day,
  ) async {
    await _manualRef.push().set({
      'time_start': time,
      'duration': duration,
      'category': category,
      'day': day,
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
      }
    }
  }

  Future<List<Map<String, dynamic>>> getSchedules() async {
    List<Map<String, dynamic>> schedules = [];

    final manualSnapshot = await _manualRef.get();
    if (manualSnapshot.exists) {
      schedules.addAll(
        (manualSnapshot.value as Map).values
            .map((e) => Map<String, dynamic>.from(e))
            .toList(),
      );
    }

    final autoSnapshot = await _autoRef.get();
    if (autoSnapshot.exists) {
      schedules.addAll(
        (autoSnapshot.value as Map).values
            .map((e) => Map<String, dynamic>.from(e))
            .toList(),
      );
    }

    return schedules;
  }

  bool _isScheduleValid(Map<String, dynamic> schedule, DateTime now) {
    final timeStart = schedule['time_start']?.toString();
    final day = schedule['day']?.toString();
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

    final category = schedule['category'];
    final duration = schedule['duration'];
    if (category == null) return;

    final audioUrl = await _getAudioUrl(category);

    if (audioUrl == null) {
      print("❌ URL audio tidak ditemukan untuk kategori: $category");
      return;
    }

    print("🔊 Memutar audio dari URL: $audioUrl selama $duration menit.");
    _isAudioPlaying = true;

    try {
      await _playerService.playMusicFromProxy(audioUrl);
      await Future.delayed(Duration(minutes: int.parse(duration)));
    } catch (e) {
      print("❌ Error saat memutar audio: $e");
    } finally {
      _isAudioPlaying = false;
    }
  }

  Future<String?> _getAudioUrl(String category) async {
    final musicUrl = await _fetchAudioUrl(_musicRef, category);
    if (musicUrl != null) return musicUrl;

    final murottalUrl = await _fetchAudioUrl(_murottalRef, category);
    return murottalUrl;
  }

  Future<String?> _fetchAudioUrl(DatabaseReference ref, String category) async {
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      for (var cat in data.values) {
        if (cat is Map && cat['title'] == category) {
          return "http://localhost:3000/drive/${cat['fileId']}";
        }
      }
    }
    return null;
  }

  void dispose() {
    _timer?.cancel();
    _playerService.stopMusic();
    print("🛑 ScheduleService dihentikan.");
  }
}
