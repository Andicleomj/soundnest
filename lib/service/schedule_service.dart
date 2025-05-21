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

  /// Ambil daftar jadwal manual dari Firebase Realtime Database.
  Future<List<Map<String, dynamic>>> getManualSchedules() async {
    final snapshot = await _manualRef.get();

    if (!snapshot.exists) {
      return [];
    }

    final value = snapshot.value;
    Map<dynamic, dynamic> dataMap;

    if (value is Map<dynamic, dynamic>) {
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
        final scheduleRaw = entry.value;
        if (scheduleRaw is! Map) continue;

        final schedule = Map<String, dynamic>.from(scheduleRaw);

        String hari;
        final hariData = schedule['hari'];

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
          'title': schedule['title'] ?? 'Tanpa Judul',
          'category': schedule['category'] ?? '-',
          'hari': hari,
          'waktu': schedule['waktu'] ?? 'Tidak ada waktu',
          'durasi': schedule['durasi']?.toString() ?? '0',
          'enabled': schedule['enabled'] ?? false,
          'file_id': schedule['file_id'] ?? '', // jika ada file_id untuk play
        });
      } catch (e) {
        schedules.add({
          'key': entry.key,
          'title': 'Format Tidak Valid',
          'category': '-',
          'hari': '-',
          'waktu': '-',
          'durasi': '0',
          'enabled': false,
          'file_id': '',
        });
      }
    }

    return schedules;
  }

  /// Update status enabled pada jadwal manual.
  Future<void> toggleScheduleEnabled(String key, bool enabled) async {
    await _manualRef.child(key).update({'enabled': enabled});
  }

  /// Mulai service pengecekan jadwal yang dijalankan secara periodik (setiap menit).
  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) async {
      await _checkAndPlaySchedules();
    });

    print('ScheduleService started...');
    // Bisa langsung cek juga saat start
    _checkAndPlaySchedules();
  }

  /// Hentikan service pengecekan jadwal.
  void stop() {
    _timer?.cancel();
    _timer = null;
    print('ScheduleService stopped.');
  }

  /// Cek jadwal yang aktif dan mainkan jika waktu cocok.
  Future<void> _checkAndPlaySchedules() async {
    final schedules = await getManualSchedules();

    final now = DateTime.now();
    final currentTimeStr = DateFormat('HH:mm').format(now);
    final currentDay = DateFormat(
      'EEEE',
    ).format(now); // Nama hari, misal "Monday"

    print('⏰ Checking schedules at $currentTimeStr on $currentDay');

    for (final schedule in schedules) {
      if (schedule['enabled'] != true) continue;

      final hariStr = schedule['hari'] as String;

      // Cek apakah jadwal berlaku hari ini
      if (hariStr == 'Setiap Hari' ||
          hariStr.split(', ').contains(currentDay)) {
        final jadwalWaktu = schedule['waktu'] as String;

        if (jadwalWaktu == currentTimeStr) {
          final fileId = schedule['file_id'] ?? '';
          final durasi = int.tryParse(schedule['durasi'] ?? '0') ?? 0;

          if (fileId.isNotEmpty) {
            print(
              '▶️ Memutar musik: ${schedule['title']} selama $durasi menit',
            );
            // Panggil play dengan durasi sebagai positional argument, sesuaikan MusicPlayerService.play
            await _playerService.playFromUrl(fileId, duration: durasi);
          } else {
            print(
              '▶️ Memutar musik: ${schedule['title']} selama $durasi menit',
            );
            // Jika tidak ada file_id, bisa panggil play dengan URL atau cara lain
            await _playerService.playFromFileId(fileId, duration: durasi);
          }
        }
      }
    }
  }
}
