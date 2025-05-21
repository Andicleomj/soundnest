import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:soundnest/service/music_player_service.dart';
import 'package:intl/intl.dart';

class ScheduleService {
  final DatabaseReference _manualRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/schedule/manual',
  );

  final MusicPlayerService _playerService = MusicPlayerService();
  Timer? _timer;

  /// Ambil daftar jadwal manual dari Firebase
  Future<List<Map<String, dynamic>>> getManualSchedules() async {
    final snapshot = await _manualRef.get();
    if (!snapshot.exists) return [];

    final value = snapshot.value;
    Map<dynamic, dynamic> dataMap;

    if (value is Map) {
      dataMap = value;
    } else if (value is List) {
      dataMap = {
        for (int i = 0; i < value.length; i++)
          if (value[i] != null) i: value[i],
      };
    } else {
      return [];
    }

    List<Map<String, dynamic>> schedules = [];

    for (var entry in dataMap.entries) {
      try {
        final raw = entry.value;
        if (raw is! Map) continue;

        final data = Map<String, dynamic>.from(raw);
        final hariData = data['hari'];
        String hari;

        if (hariData is String) {
          hari = hariData;
        } else if (hariData is List) {
          hari = hariData.join(', ');
        } else if (hariData is Map) {
          hari = hariData.values.join(', ');
        } else {
          hari = '-';
        }

        schedules.add({
          'key': entry.key,
          'title': data['title'] ?? 'Tanpa Judul',
          'category': data['category'] ?? '-',
          'hari': hari,
          'waktu': data['waktu'] ?? '-',
          'durasi': data['durasi']?.toString() ?? '0',
          'enabled': data['enabled'] ?? false,
          'file_id': data['file_id'] ?? '',
        });
      } catch (e) {
        print('❌ Error parsing schedule: $e');
      }
    }

    return schedules;
  }

  /// Update status enabled
  Future<void> toggleScheduleEnabled(String key, bool enabled) async {
    await _manualRef.child(key).update({'enabled': enabled});
  }

  /// Start checker tiap menit
  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) async {
      await _checkAndPlaySchedules();
    });
    print('✅ ScheduleService started.');
    _checkAndPlaySchedules(); // Jalankan langsung saat start
  }

  /// Stop checker
  void stop() {
    _timer?.cancel();
    _timer = null;
    print('🛑 ScheduleService stopped.');
  }

  /// Cek dan mainkan jadwal sesuai waktu & hari
  Future<void> _checkAndPlaySchedules() async {
    final schedules = await getManualSchedules();
    final now = DateTime.now();
    final currentTime = DateFormat('HH:mm').format(now);
    final currentDay = DateFormat('EEEE').format(now); // "Monday", dll

    print('⏰ Checking schedules at $currentTime on $currentDay');

    for (final schedule in schedules) {
      if (schedule['enabled'] != true) continue;

      final hariStr = schedule['hari'] ?? '-';
      final jadwalWaktu = schedule['waktu'] ?? '-';

      final isToday =
          hariStr == 'Setiap Hari' || hariStr.split(', ').contains(currentDay);

      if (isToday && jadwalWaktu == currentTime) {
        final fileId = schedule['file_id'] ?? '';
        final durasi = int.tryParse(schedule['durasi'] ?? '0') ?? 0;

        print('🎵 Jadwal cocok → ${schedule['title']} (durasi: $durasi menit)');

        if (fileId.isNotEmpty) {
          await _playerService.playFromFileId(fileId, duration: durasi);
        } else {
          print('⚠️ Jadwal "${schedule['title']}" tidak memiliki file_id.');
        }
      }
    }
  }
}
