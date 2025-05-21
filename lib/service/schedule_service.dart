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

    final data = (snapshot.value as Map).entries.toList();
    return data.map((entry) {
      final schedule = Map<String, dynamic>.from(entry.value);
      final hariMap = schedule['hari'] as Map?;
      final hariList =
          hariMap != null
              ? hariMap.values.map((e) => e.toString()).toList()
              : [];

      return {
        'key': entry.key,
        'title': schedule['title'] ?? 'No Title',
        'category': schedule['category'] ?? '-',
        'hari': hariList,
        'waktu': schedule['waktu'],
        'durasi': schedule['durasi']?.toString(),
        'enabled': schedule['enabled'] == true,
        'fileId': schedule['file_id'],
      };
    }).toList();
  }

  bool _isScheduleValid(Map<String, dynamic> schedule, DateTime now) {
    final waktu = schedule['waktu'];
    final hariList = schedule['hari'];

    if (waktu == null || hariList == null || hariList is! List) return false;

    try {
      final inputFormat = DateFormat.jm(); // '9:38 PM'
      final jadwalTime = inputFormat.parse(waktu);
      final nowTime = DateTime(0, 0, 0, now.hour, now.minute);

      final today = _getHariNow();

      return hariList.contains(today) &&
          jadwalTime.hour == nowTime.hour &&
          jadwalTime.minute == nowTime.minute;
    } catch (e) {
      print("❌ Format waktu salah: $waktu");
      return false;
    }
  }

  String _getHariNow() {
    const hari = [
      "Senin",
      "Selasa",
      "Rabu",
      "Kamis",
      "Jumat",
      "Sabtu",
      "Minggu",
    ];
    return hari[DateTime.now().weekday - 1];
  }

  Future<void> _runScheduledAudio(Map<String, dynamic> schedule) async {
    final audioUrl = "http://localhost:3000/drive/${schedule['fileId']}";

    _isAudioPlaying = true;
    await _playerService.play(audioUrl);

    final duration = int.tryParse(schedule['durasi'] ?? '1') ?? 1;
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
