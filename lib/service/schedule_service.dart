import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:soundnest/service/music_player_service.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class ScheduleService {
  final DatabaseReference _manualRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/schedule/manual',
  );

  final MusicPlayerService _playerService = MusicPlayerService();
  Timer? _timer;
  bool _initialized = false;

  /// Inisialisasi locale untuk format hari (Indonesia)
  Future<void> initialize() async {
    if (!_initialized) {
      await initializeDateFormatting('id_ID', null);
      _initialized = true;
      print('✅ Locale id_ID initialized.');
    }
  }

  /// Ambil dan parse semua jadwal manual dari Firebase
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
        final fileId = data['file_id'] ?? data['fileId'] ?? '';
        final hariData = data['hari'];

        String hari = switch (hariData) {
          String s => s,
          List l => l.join(', '),
          Map m => m.values.join(', '),
          _ => '-',
        };

        schedules.add({
          'key': entry.key,
          'title': data['title'] ?? 'Tanpa Judul',
          'category': data['category'] ?? '-',
          'hari': hari,
          'waktu': data['waktu'] ?? '-',
          'enabled': data['enabled'] ?? false,
          'file_id': fileId,
        });
      } catch (e) {
        print('❌ Error parsing schedule: $e');
      }
    }

    return schedules;
  }

  /// Mengaktifkan/menonaktifkan jadwal
  Future<void> toggleScheduleEnabled(String key, bool enabled) async {
    await _manualRef.child(key).update({'enabled': enabled});
  }

  /// Mulai pengecekan periodik jadwal (tiap 30 detik)
  void start() async {
    if (!_initialized) {
      await initialize();
    }
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await _checkAndPlaySchedules();
    });
    print('✅ ScheduleService started.');
    _checkAndPlaySchedules(); // jalan langsung sekali saat start
  }

  /// Stop pengecekan periodik
  void stop() {
    _timer?.cancel();
    _timer = null;
    print('🛑 ScheduleService stopped.');
  }

  /// Cek semua jadwal, jika sesuai hari dan waktu → play
  Future<void> _checkAndPlaySchedules() async {
    final schedules = await getManualSchedules();
    final now = DateTime.now();
    final currentDay = DateFormat('EEEE', 'id_ID').format(now);
    final currentTime = DateFormat('h:mm a').format(now); // tanpa leading zero

    print('🕒 Sekarang: $currentDay $currentTime');

    for (final schedule in schedules) {
      if (schedule['enabled'] != true) continue;

      final hariStr = schedule['hari'] as String;
      final jadwalWaktu = schedule['waktu'] as String;
      final isToday =
          hariStr == 'Setiap Hari' || hariStr.split(', ').contains(currentDay);

      print(
        '🔍 Cek jadwal: ${schedule['title']} → Hari: $hariStr, Waktu: $jadwalWaktu',
      );

      if (isToday && jadwalWaktu == currentTime) {
        final fileId = schedule['file_id'] ?? '';

        if (fileId.isNotEmpty) {
          print('▶️ Memutar: ${schedule['title']} dengan file_id $fileId');
          await _playerService.playFromFileId(fileId);
        } else {
          print('⚠️ File ID kosong untuk jadwal: ${schedule['title']}');
        }
      }
    }
  }
}
