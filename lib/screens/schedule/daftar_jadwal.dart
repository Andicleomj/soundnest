import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'dart:math';

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
    'devices/devices_01/musik',
  );
  final DatabaseReference _murottalRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/murottal',
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
      List<Map<String, dynamic>> autoList = [];

      if (schedule['content'] != null) {
        autoList.add(await _fetchContent(schedule['content'], _musicRef));
      }

      if (schedule['content_murottal'] != null) {
        autoList.add(
          await _fetchContent(schedule['content_murottal'], _murottalRef),
        );
      }

      setState(() {
        _autoSchedules = autoList;
      });
    }
  }

  Future<Map<String, dynamic>> _fetchContent(
    String category,
    DatabaseReference ref,
  ) async {
    final categorySnapshot = await ref.child(category).get();

    if (categorySnapshot.exists && categorySnapshot.value is Map) {
      final contents = (categorySnapshot.value as Map).values.toList();
      final randomContent = contents[Random().nextInt(contents.length)];
      return Map<String, dynamic>.from(randomContent);
    }

    return {'title': 'Konten tidak tersedia', 'file_id': ''};
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
      appBar: AppBar(
        title: const Text("Penjadwalan Musik & Murottal"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
                : _buildScheduleList(_manualSchedules),
            const SizedBox(height: 16),
            const Text(
              "Jadwal Otomatis",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _autoSchedules.isEmpty
                ? const Text("Tidak ada jadwal otomatis.")
                : _buildScheduleList(_autoSchedules),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleList(List<Map<String, dynamic>> schedules) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        return ListTile(
          title: Text(schedule['title'] ?? 'Tanpa Judul'),
          subtitle: Text("File ID: ${schedule['file_id']}"),
        );
      },
    );
  }
}
