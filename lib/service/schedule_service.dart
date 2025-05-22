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

  /// Inisialisasi locale date formatting
  Future<void> initialize() async {
    if (!_initialized) {
      await initializeDateFormatting('id_ID', null);
      _initialized = true;
      print('✅ Locale id_ID initialized.');
    }
  }

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

        // Ambil file_id atau fileId dari data, prioritaskan file_id
        final fileId = data['file_id'] ?? data['fileId'] ?? '';

        schedules.add({
          'key': entry.key,
          'title': data['title'] ?? 'Tanpa Judul',
          'category': data['category'] ?? '-',
          'hari': hari,
          'waktu': data['waktu'] ?? '-',
          'durasi': data['durasi']?.toString() ?? '0',
          'enabled': data['enabled'] ?? false,
          'file_id': fileId,
        });
      } catch (e) {
        print('❌ Error parsing schedule: $e');
      }
    }

    return schedules;
  }

  Future<void> toggleScheduleEnabled(String key, bool enabled) async {
    await _manualRef.child(key).update({'enabled': enabled});
  }

  void start() async {
    if (!_initialized) {
      await initialize();
    }
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) async {
      await _checkAndPlaySchedules();
    });
    print('✅ ScheduleService started.');
    _checkAndPlaySchedules(); // langsung jalan saat start
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    print('🛑 ScheduleService stopped.');
  }

  Future<void> _checkAndPlaySchedules() async {
    final schedules = await getManualSchedules();
    final now = DateTime.now();

    final currentDay = DateFormat('EEEE', 'id_ID').format(now);
    final currentTime12h = DateFormat('hh:mm a').format(now);

    for (final schedule in schedules) {
      if (schedule['enabled'] != true) continue;

      final hariStr = schedule['hari'] as String;
      final jadwalWaktu = schedule['waktu'] as String;

      final isToday =
          hariStr == 'Setiap Hari' || hariStr.split(', ').contains(currentDay);

      if (isToday && jadwalWaktu == currentTime12h) {
        final fileId = schedule['file_id'] ?? '';
        final durasi = int.tryParse(schedule['durasi'] ?? '0') ?? 0;

        print('🎵 Jadwal cocok → ${schedule['title']} (durasi: $durasi menit)');

        if (fileId.isNotEmpty) {
          print(
            '▶️ Memutar musik/murottal: ${schedule['title']} dengan file_id $fileId selama $durasi menit',
          );
          await _playerService.playFromFileId(fileId, duration: durasi);
        } else {
          print('⚠️ File ID kosong untuk jadwal: ${schedule['title']}');
        }
      }
    }
  }
}
