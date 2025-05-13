import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'g_drive_audio_service.dart';

class ScheduleService {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref(
    'devices/devices_01/schedule_001/-Nxyz12345',
  );
  final GoogleDriveAudioService _audioService = GoogleDriveAudioService();
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
        final rawSchedules = (snapshot.value as Map).values;

        // Hanya ambil data yang bertipe Map<String, dynamic>
        return rawSchedules
            .where((e) => e is Map<String, dynamic>)
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
      // Tambahkan pengecekan isActive
      if (!(schedule['isActive'] ?? true)) {
        print("❌ Jadwal dinonaktifkan: ${schedule['name'] ?? 'Tanpa Nama'}");
        continue;
      }

      if (!_isScheduleValid(schedule, now)) continue;

      await _runScheduledAudio(schedule, now);
      print("✅ Audio dijalankan.");
    }
  }

  Future<void> _runScheduledAudio(
    Map<String, dynamic> schedule,
    DateTime now,
  ) async {
    final fileId = schedule['file_id'];
    if (fileId == null) return;

    _isAudioPlaying = true;
    await _audioService.playFromGoogleDrive(fileId);
    _isAudioPlaying = false;

    print("🎶 Audio dimainkan sesuai jadwal: ${schedule['time_start']}.");
  }

  bool _isScheduleValid(Map<String, dynamic> schedule, DateTime now) {
    final day = schedule['day']?.toLowerCase();
    final timeStart = schedule['time_start'];

    if (day == null || timeStart == null || schedule['file_id'] == null) {
      return false;
    }

    if (day != _getDayOfWeek(now)) return false;

    final parts = timeStart.split(':');
    if (parts.length != 2) return false;

    final scheduleHour = int.tryParse(parts[0]);
    final scheduleMinute = int.tryParse(parts[1]);

    return now.hour == scheduleHour && now.minute == scheduleMinute;
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

  Future<void> addSchedule(Map<String, dynamic> scheduleData) async {
    await _ref.push().set(scheduleData);
    print("📅 Jadwal baru ditambahkan: $scheduleData");
  }

  void dispose() {
    _timer?.cancel();
    _audioService.dispose();
    print("🛑 ScheduleService dihentikan.");
  }
}
