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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    try {
      final manualSnapshot = await _manualRef.get();
      print("Manual Schedules Snapshot: ${manualSnapshot.value}");

      setState(() {
        _manualSchedules =
            manualSnapshot.exists && manualSnapshot.value is Map
                ? (manualSnapshot.value as Map).values
                    .map((e) => Map<String, dynamic>.from(e))
                    .toList()
                : [];
      });

      final autoSnapshot =
          await _autoRef.child(_getDayName(DateTime.now())).get();
      if (autoSnapshot.exists && autoSnapshot.value is Map) {
        _loadAutoSchedules(autoSnapshot.value);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading schedules: $e");
    }
  }

  void _loadAutoSchedules(dynamic data) {
    final autoData = Map<String, dynamic>.from(data);
    _autoSchedules = [];

    if (autoData.containsKey('content')) {
      _fetchContent(autoData['content'], _musicRef);
    }
    if (autoData.containsKey('content_murottal')) {
      _fetchContent(autoData['content_murottal'], _murottalRef);
    }
  }

  Future<void> _fetchContent(String category, DatabaseReference ref) async {
    final snapshot = await ref.child(category).get();
    if (snapshot.exists && snapshot.value is Map) {
      final contentList = (snapshot.value as Map).values.toList();
      final randomContent =
          contentList.isNotEmpty
              ? contentList[Random().nextInt(contentList.length)]
              : {};

      setState(() {
        _autoSchedules.add({
          'title': randomContent['title'] ?? 'Tanpa Judul',
          'file_id': randomContent['file_id'] ?? 'Tidak ada',
        });
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
      appBar: AppBar(
        title: const Text("Penjadwalan Musik & Murottal"),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Jadwal Manual",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _manualSchedules.isEmpty
                        ? const Text("Tidak ada jadwal manual.")
                        : _buildScheduleList(_manualSchedules),
                    const SizedBox(height: 16),
                    const Text(
                      "Jadwal Otomatis",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
          subtitle: Text("File ID: ${schedule['file_id'] ?? 'Tidak ada'}"),
        );
      },
    );
  }
}
