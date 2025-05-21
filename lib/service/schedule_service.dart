import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:soundnest/service/music_player_service.dart';
import 'package:intl/intl.dart';

class ScheduleService {
  final DatabaseReference _manualRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/schedule/manual',
  );

  /// Ambil daftar jadwal manual dari Firebase Realtime Database.
  Future<List<Map<String, dynamic>>> getManualSchedules() async {
    final snapshot = await _manualRef.get();

    if (!snapshot.exists) {
      // Jika data tidak ada, kembalikan list kosong
      return [];
    }

    final value = snapshot.value;

    Map<dynamic, dynamic> dataMap;

    // Cek tipe data dari Firebase
    if (value is Map<dynamic, dynamic>) {
      dataMap = value;
    } else if (value is List) {
      // Jika data berupa List, konversi jadi Map dengan index sebagai key
      dataMap = {
        for (int i = 0; i < value.length; i++)
          if (value[i] != null) i: value[i],
      };
    } else {
      // Jika tipe data lain (null atau bukan Map/List), kembalikan kosong
      return [];
    }

    List<Map<String, dynamic>> schedules = [];

    // Proses setiap entry dalam dataMap
    for (var entry in dataMap.entries) {
      try {
        final scheduleRaw = entry.value;
        if (scheduleRaw is! Map) continue; // Skip kalau bukan Map

        final schedule = Map<String, dynamic>.from(scheduleRaw);

        // Parsing field hari yang bisa berupa String, List, atau Map
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
        });
      } catch (e) {
        // Kalau parsing error, masukkan jadwal default supaya tidak error
        schedules.add({
          'key': entry.key,
          'title': 'Format Tidak Valid',
          'category': '-',
          'hari': '-',
          'waktu': '-',
          'durasi': '0',
          'enabled': false,
        });
      }
    }

    return schedules;
  }

  /// Update status enabled pada jadwal manual.
  Future<void> toggleScheduleEnabled(String key, bool enabled) async {
    await _manualRef.child(key).update({'enabled': enabled});
  }
}
