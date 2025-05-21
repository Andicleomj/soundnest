import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:soundnest/service/music_player_service.dart';
import 'package:intl/intl.dart';

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
      print(
        "🔎 ${schedule['title']} | ${schedule['hari']} | ${schedule['waktu']}",
      );
      if ((schedule['enabled'] ?? false) && _isScheduleValid(schedule, now)) {
        await _runScheduledAudio(schedule);
        break;
      }
    }
  }

  Future<List<Map<String, dynamic>>> getSchedules() async {
    final snapshot = await _manualRef.get();
    if (!snapshot.exists) return [];

    final List<Map<String, dynamic>> schedules = [];
    final value = snapshot.value;

    if (value is Map) {
      value.forEach((key, raw) {
        if (raw is! Map) return;
        final schedule = Map<String, dynamic>.from(raw);

        final hariData = schedule['hari'];
        final hariList =
            (hariData is Map)
                ? hariData.values.map((e) => e.toString()).toList()
                : (hariData is List)
                ? hariData.map((e) => e.toString()).toList()
                : (hariData is String)
                ? [hariData]
                : [];

        schedules.add({
          'key': key,
          'title': schedule['title'] ?? 'No Title',
          'category': schedule['category'] ?? '-',
          'hari': hariList,
          'waktu': schedule['waktu'],
          'durasi': schedule['durasi']?.toString(),
          'enabled': schedule['enabled'] == true,
          'fileId': schedule['file_id'],
        });
      });
    } else if (value is List) {
      for (int i = 0; i < value.length; i++) {
        final raw = value[i];
        if (raw is! Map) continue;
        final schedule = Map<String, dynamic>.from(raw);

        final hariData = schedule['hari'];
        final hariList =
            (hariData is Map)
                ? hariData.values.map((e) => e.toString()).toList()
                : (hariData is List)
                ? hariData.map((e) => e.toString()).toList()
                : (hariData is String)
                ? [hariData]
                : [];

        schedules.add({
          'key': i.toString(),
          'title': schedule['title'] ?? 'No Title',
          'category': schedule['category'] ?? '-',
          'hari': hariList,
          'waktu': schedule['waktu'],
          'durasi': schedule['durasi']?.toString(),
          'enabled': schedule['enabled'] == true,
          'fileId': schedule['file_id'],
        });
      }
    } else {
      print("⚠️ Format data tidak dikenali: ${value.runtimeType}");
    }

    return schedules;
  }

  Future<void> _runScheduledAudio(Map<String, dynamic> schedule) async {
    final fileId = schedule['fileId'];
    final durasiStr = schedule['durasi'];
    final duration = durasiStr != null ? int.tryParse(durasiStr) : null;

    if (fileId == null) {
      print("⚠️ Jadwal tidak memiliki fileId.");
      return;
    }

    _isAudioPlaying = true;
    try {
      await _playerService.play(fileId, duration: duration);
      print("▶️ Memutar audio untuk jadwal: ${schedule['title']}");
    } catch (e) {
      print("❌ Gagal memutar audio: $e");
    } finally {
      _isAudioPlaying = false;
    }
  }

  bool _isScheduleValid(Map<String, dynamic> schedule, DateTime now) {
    final hariList = schedule['hari'] as List;
    final waktu = schedule['waktu'] as String?;
    if (hariList.isEmpty || waktu == null || waktu.isEmpty) return false;

    final today = DateFormat('EEEE', 'id_ID').format(now);
    if (!hariList.contains(today)) return false;

    try {
      final parts = waktu.split(":");
      final jam = int.parse(parts[0]);
      final menit = int.parse(parts[1]);

      final jadwalTime = DateTime(now.year, now.month, now.day, jam, menit);
      return now.hour == jadwalTime.hour && now.minute == jadwalTime.minute;
    } catch (e) {
      print("❌ Format waktu salah: $waktu");
      return false;
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    print("⏹️ ScheduleService stopped.");
  }

  void dispose() {
    stop();
    _playerService.dispose();
  }
}
