import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:soundnest/service/music_player_service.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class ScheduleService {
  final DatabaseReference _manualRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/schedule/manual',
  );
  final DatabaseReference _otomatisRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/schedule/otomatis',
  );

  final MusicPlayerService _playerService = MusicPlayerService();
  Timer? _timer;
  bool _initialized = false;

  // 🔒 Variabel untuk mencegah pemutaran ulang dalam 1 menit
  DateTime? _lastPlayedTime;
  String? _lastPlayedScheduleKey;

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
    print("📡 Data Firebase: ${snapshot.value}");
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
        final fileId = data['fileId'] ?? '';
        final hariData = data['hari'];

        String hari = switch (hariData) {
          String s => s,
          List l => l.join(', '),
          Map m => m.values.join(', '),
          _ => '-',
        };

        schedules.add({
          'key': entry.key.toString(),
          'title': data['title'] ?? (data['category'] ?? 'Tanpa Judul'),
          'category': data['category'] ?? '-',
          'hari': hari,
          'startTime': data['startTime'] ?? '',
          'endTime': data['endTime'] ?? '',
          'enabled': data['enabled'] ?? false,
          'fileId': fileId,
          'source': 'manual',
        });
      } catch (e) {
        print('❌ Error parsing schedule: $e');
      }
    }

    return schedules;
  }

  /// Ambil dan parse semua jadwal otomatis dari Firebase
  Future<List<Map<String, dynamic>>> getOtomatisSchedules() async {
    final snapshot = await _otomatisRef.get();
    print("📡 Data Firebase: ${snapshot.value}");
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
        final fileId = data['fileId'] ?? '';
        final hariData = data['hari'];

        String hari = switch (hariData) {
          String s => s,
          List l => l.join(', '),
          Map m => m.values.join(', '),
          _ => '-',
        };

        schedules.add({
          'key': entry.key.toString(),
          'title': data['title'] ?? (data['category'] ?? 'Tanpa Judul'),
          'category': data['category'] ?? '-',
          'hari': hari,
          'startTime': data['startTime'] ?? '',
          'endTime': data['endTime'] ?? '',
          'enabled': data['enabled'] ?? false,
          'fileId': fileId,
          'source': 'otomatis',
        });
      } catch (e) {
        print('❌ Error parsing otomatis schedule: $e');
      }
    }

    return schedules;
  }

  /// Mengaktifkan/menonaktifkan jadwal (manual saja)
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
    _checkAndPlaySchedules();
  }

  /// Stop pengecekan periodik
  void stop() {
    _timer?.cancel();
    _timer = null;
    print('🛑 ScheduleService stopped.');
  }

  /// Cek semua jadwal manual dan otomatis, jika sesuai hari dan waktu → play
  Future<void> _checkAndPlaySchedules() async {
    final manualSchedules = await getManualSchedules();
    final otomatisSchedules = await getOtomatisSchedules();

    final schedules = [...manualSchedules, ...otomatisSchedules];
    final now = DateTime.now();
    final currentDay = DateFormat('EEEE', 'id_ID').format(now);
    final currentTime = DateFormat('HH:mm').format(now);

    print('🕒 Sekarang: $currentDay $currentTime');

    for (final schedule in schedules) {
      if (schedule['enabled'] != true) continue;

      final key = schedule['key'] as String;
      final hariStr = schedule['hari'] as String;
      final startTimeStr = schedule['startTime'] as String;
      final endTimeStr = schedule['endTime'] as String;

      if (startTimeStr.isEmpty || endTimeStr.isEmpty) continue;

      final isToday =
          hariStr == 'Setiap Hari' || hariStr.split(', ').contains(currentDay);

      final alreadyPlayed =
          _lastPlayedScheduleKey == key &&
          _lastPlayedTime != null &&
          now.difference(_lastPlayedTime!).inMinutes < 1;

      final startTime = DateFormat('HH:mm').parse(startTimeStr);
      final endTime = DateFormat('HH:mm').parse(endTimeStr);
      final nowTime = DateFormat('HH:mm').parse(currentTime);

      final inTimeRange =
          nowTime.isAfter(startTime.subtract(const Duration(seconds: 1))) &&
          nowTime.isBefore(endTime.add(const Duration(seconds: 1)));

      print(
        '🔍 Cek jadwal (${schedule['source']}): ${schedule['title']} → Hari: $hariStr, Waktu: $startTimeStr - $endTimeStr, Already played: $alreadyPlayed',
      );

      if (isToday && inTimeRange && !alreadyPlayed) {
        final fileId = schedule['fileId'] ?? '';

        if (fileId.isNotEmpty) {
          try {
            print(
              '▶️ Memutar (${schedule['source']}): ${schedule['title']} dengan fileId $fileId',
            );
            await _playerService.playFromFileId(fileId);

            _lastPlayedScheduleKey = key;
            _lastPlayedTime = now;
          } catch (e) {
            print('❌ Gagal memutar file: $e');
          }
        } else {
          print('⚠️ File ID kosong untuk jadwal: ${schedule['title']}');
        }
      }
    }
  }
}
