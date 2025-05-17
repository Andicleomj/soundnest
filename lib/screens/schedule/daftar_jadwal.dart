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

  List<Map<String, dynamic>> _manualSchedules = [];
  List<Map<String, dynamic>> _autoSchedules = [];

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    final manualSnapshot = await _manualRef.get();
    if (manualSnapshot.exists && manualSnapshot.value is Map) {
      final schedules = Map<String, dynamic>.from(manualSnapshot.value as Map);
      setState(() {
        _manualSchedules =
            schedules.entries
                .map((entry) => Map<String, dynamic>.from(entry.value))
                .toList();
      });
    }

    final currentDay = _getDayName(DateTime.now());
    final autoSnapshot = await _autoRef.child(currentDay).get();
    if (autoSnapshot.exists && autoSnapshot.value is Map) {
      final schedule = Map<String, dynamic>.from(autoSnapshot.value as Map);
      setState(() {
        _autoSchedules = [schedule];
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Penjadwalan Musik"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Jadwal Manual",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _manualSchedules.isEmpty
                ? const Text("Tidak ada jadwal manual.")
                : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _manualSchedules.length,
                  itemBuilder: (context, index) {
                    final schedule = _manualSchedules[index];
                    return ListTile(
                      title: Text(
                        "${schedule['time_start']} - ${schedule['time_end']}",
                      ),
                      subtitle: Text("Konten: ${schedule['content']}"),
                    );
                  },
                ),
            const SizedBox(height: 16),
            const Text(
              "Jadwal Otomatis",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _autoSchedules.isEmpty
                ? const Text("Tidak ada jadwal otomatis hari ini.")
                : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _autoSchedules.length,
                  itemBuilder: (context, index) {
                    final schedule = _autoSchedules[index];
                    return ListTile(
                      title: Text(
                        "${schedule['time']} (Durasi: ${schedule['duration']})",
                      ),
                      subtitle: Text(
                        "Konten: ${schedule['cotent']?.join(', ')}",
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}
