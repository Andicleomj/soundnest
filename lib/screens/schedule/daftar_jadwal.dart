import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class DaftarJadwal extends StatefulWidget {
  const DaftarJadwal({super.key});

  @override
  _DaftarJadwalState createState() => _DaftarJadwalState();
}

class _DaftarJadwalState extends State<DaftarJadwal> {
  final DatabaseReference _manualRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/schedule/manual',
  );
  final DatabaseReference _autoRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/schedule/otomatis',
  );
  final DatabaseReference _musicRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/music/categories',
  );

  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _scheduleTimer;

  @override
  void initState() {
    super.initState();
    _startScheduleChecker();
  }

  void _startScheduleChecker() {
    _scheduleTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      final now = DateTime.now();
      await _checkManualSchedules(now);
      await _checkAutomaticSchedules(now);
    });
  }

  Future<void> _checkManualSchedules(DateTime now) async {
    final snapshot = await _manualRef.get();
    if (snapshot.exists && snapshot.value is Map) {
      final schedules = Map<String, dynamic>.from(snapshot.value as Map);
      for (var entry in schedules.entries) {
        final schedule = entry.value;
        if (schedule['isActive'] == true) {
          final startTime = DateTime.tryParse(schedule['time_start'] ?? '');
          final endTime = DateTime.tryParse(schedule['time_end'] ?? '');

          if (startTime != null &&
              endTime != null &&
              now.isAfter(startTime) &&
              now.isBefore(endTime)) {
            await _playMusic(schedule['content']);
            return; // Prioritaskan jadwal manual
          }
        }
      }
    }
  }

  Future<void> _checkAutomaticSchedules(DateTime now) async {
    final currentDay = _getDayName(now);
    final autoScheduleSnapshot = await _autoRef.child(currentDay).get();

    if (autoScheduleSnapshot.exists && autoScheduleSnapshot.value is Map) {
      final schedule = Map<String, dynamic>.from(
        autoScheduleSnapshot.value as Map,
      );
      if (schedule.containsKey('time') &&
          schedule.containsKey('duration') &&
          schedule.containsKey('content')) {
        final timeParts = schedule['time'].split(':');
        final startTime = DateTime(
          now.year,
          now.month,
          now.day,
          int.tryParse(timeParts[0]) ?? 0,
          int.tryParse(timeParts[1]) ?? 0,
        );
        final duration = Duration(
          minutes: int.tryParse(schedule['duration'].split(':')[1]) ?? 0,
        );
        final endTime = startTime.add(duration);

        if (now.isAfter(startTime) && now.isBefore(endTime)) {
          final categories = List<String>.from(schedule['cotent'] ?? []);
          if (categories.isNotEmpty) {
            final index = now.weekday % categories.length;
            await _playMusic(categories[index]);
          }
        }
      }
    }
  }

  String _getDayName(DateTime date) {
    const days = [
      'senin',
      'selasa',
      'rabu',
      'kamis',
      'jumat',
      'sabtu',
      'minggu',
    ];
    return days[(date.weekday - 1) % 7];
  }

  Future<void> _playMusic(String categoryId) async {
    final musicSnapshot = await _musicRef.child(categoryId).get();
    if (musicSnapshot.exists && musicSnapshot.value is Map) {
      final musicData = Map<String, dynamic>.from(musicSnapshot.value as Map);
      final fileId = musicData['file_id'];
      if (fileId != null) {
        final url = 'http://localhost:3000/stream/$fileId';
        await _audioPlayer.play(UrlSource(url));
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _scheduleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Penjadwalan Musik"), centerTitle: true),
      body: const Center(child: Text("Jadwal Otomatis dan Manual")),
    );
  }
}
