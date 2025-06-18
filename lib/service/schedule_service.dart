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

  DateTime? _lastPlayedTime;
  String? _lastPlayedScheduleKey;

  Future<void> initialize() async {
    if (!_initialized) {
      await initializeDateFormatting('id_ID', null);
      _initialized = true;
      print('✅ Locale id_ID initialized.');
    }
  }

  Future<List<Map<String, dynamic>>> getAllSchedules(
    DatabaseReference ref,
    String source,
  ) async {
    final snapshot = await ref.get();
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

        String hari = switch (hariData) {
          String s => s,
          List l => l.join(', '),
          Map m => m.values.join(', '),
          _ => '-',
        };

        schedules.add({
          'key': entry.key.toString(),
          'title': data['title'] ?? '-',
          'category': data['category'] ?? '-',
          'hari': hari,
          'startTime': data['startTime'] ?? '',
          'endTime': data['endTime'] ?? '',
          'enabled': data['enabled'] ?? false,
          'murottalList': data['murottalList'] ?? [],
          'source': source,
        });
      } catch (e) {
        print('❌ Error parsing $source schedule: $e');
      }
    }
    return schedules;
  }

  Future<void> toggleScheduleEnabled(String key, bool enabled) async {
    await _manualRef.child(key).update({'enabled': enabled});
  }

  void start() async {
    if (!_initialized) await initialize();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await _checkAndPlaySchedules();
    });
    print('✅ ScheduleService started.');
    _checkAndPlaySchedules();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    print('🛑 ScheduleService stopped.');
  }

  Future<void> _checkAndPlaySchedules() async {
    final now = DateTime.now();
    final currentDay = DateFormat('EEEE', 'id_ID').format(now);
    final nowTime = DateFormat('HH:mm').parse(DateFormat('HH:mm').format(now));

    final schedules = [
      ...await getAllSchedules(_manualRef, 'manual'),
      ...await getAllSchedules(_otomatisRef, 'otomatis'),
    ];

    for (final schedule in schedules) {
      if (schedule['enabled'] != true) continue;

      final key = schedule['key'] as String;
      final hariStr = schedule['hari'] as String;
      final startTimeStr = schedule['startTime'] as String;
      final endTimeStr = schedule['endTime'] as String;

      if (startTimeStr.isEmpty || endTimeStr.isEmpty) continue;

      final startTime = DateFormat('HH:mm').parse(startTimeStr);
      final endTime = DateFormat('HH:mm').parse(endTimeStr);

      final isToday =
          hariStr == 'Setiap Hari' || hariStr.split(', ').contains(currentDay);

      final alreadyPlayed =
          _lastPlayedScheduleKey == key &&
          _lastPlayedTime != null &&
          now.difference(_lastPlayedTime!).inMinutes < 1;

      final inTimeRange =
          nowTime.isAfter(startTime.subtract(const Duration(seconds: 1))) &&
          nowTime.isBefore(endTime.add(const Duration(seconds: 1)));

      if (isToday && inTimeRange && !alreadyPlayed) {
        final murottalList = schedule['murottalList'];
        if (murottalList is List && murottalList.isNotEmpty) {
          print('▶️ Mulai memutar jadwal: ${schedule['title']}');
          await _playMurottalListSequentially(murottalList, endTime);
          _lastPlayedScheduleKey = key;
          _lastPlayedTime = now;
        }
      }
    }
  }

  Future<void> _playMurottalListSequentially(
    List murottalList,
    DateTime endTime,
  ) async {
    for (var item in murottalList) {
      if (item is! Map) continue;

      final fileId = item['fileId'];
      final title = item['title'];

      if (fileId == null || fileId.toString().isEmpty) continue;

      final now = DateTime.now();
      if (now.isAfter(endTime)) {
        print('⏹️ Waktu habis, berhenti memutar.');
        break;
      }

      print('🎵 Memutar: $title');
      await _playerService.playFromFileId(fileId.toString());
    }
  }
}
