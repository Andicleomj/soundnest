import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'g_drive_audio_service.dart';
import 'notifikasi_service.dart';

final NotificationService _notificationService = NotificationService();

class ScheduleService {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref(
    'devices/device_001/schedules',
  );

  final GoogleDriveAudioService _audioService = GoogleDriveAudioService();
  Timer? _timer;

  // Ambil semua jadwal
  Future<List<Map<String, dynamic>>> getSchedules() async {
    final snapshot = await _ref.get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return data.values.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      return [];
    }
  }

  // Tambahkan jadwal baru
  Future<void> addSchedule(Map<String, dynamic> scheduleData) async {
    await _ref.push().set(scheduleData);
  }

  // Mulai pengecekan berkala setiap menit
  void startScheduleChecker() {
    _timer?.cancel(); // Hentikan timer sebelumnya jika ada
    _timer = Timer.periodic(const Duration(minutes: 1), (_) async {
      await checkAndRunSchedule();
    });
  }

  // Logika pengecekan dan eksekusi jadwal
  Future<void> checkAndRunSchedule() async {
    final now = TimeOfDay.now();
    final schedules = await getSchedules();

    for (var schedule in schedules) {
      final day = schedule['day'];
      final timeStart = schedule['time_start'];
      final fileId =
          schedule['file_id']; // Menggunakan file_id dari Google Drive

      if (day == null || timeStart == null || fileId == null) continue;

      final nowDay = getDayOfWeek(now);
      if (day != nowDay) continue;

      final parts = timeStart.split(':');
      if (parts.length != 2) continue;

      final jadwal = TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 0,
        minute: int.tryParse(parts[1]) ?? 0,
      );

      if (now.hour == jadwal.hour && now.minute == jadwal.minute) {
        print('⏰ Jadwal cocok, menjalankan aksi untuk $timeStart');
        await _audioService.playFromGoogleDrive(fileId);
        await _notificationService.showNotification(
          "Jadwal Aktif",
          "Memutar audio sesuai jadwal pada $timeStart",
        );
      }
    }
  }

  // Fungsi untuk mendapatkan nama hari dalam bahasa Indonesia
  String getDayOfWeek(TimeOfDay now) {
    final days = [
      'senin',
      'selasa',
      'rabu',
      'kamis',
      'jumat',
      'sabtu',
      'minggu',
    ];
    final weekday = DateTime.now().weekday;
    return days[weekday - 1];
  }

  void dispose() {
    _timer?.cancel();
    _audioService.dispose();
  }
}
