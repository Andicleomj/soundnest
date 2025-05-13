import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DaftarJadwal extends StatefulWidget {
  const DaftarJadwal({super.key});

  @override
  _DaftarJadwalState createState() => _DaftarJadwalState();
}

class _DaftarJadwalState extends State<DaftarJadwal> {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref(
    'devices/device_01/schedule_001',
  );
  List<Map<String, dynamic>> _schedules = [];

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    final snapshot = await _ref.get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      setState(() {
        _schedules =
            data.entries
                .map(
                  (e) => {"key": e.key, ...Map<String, dynamic>.from(e.value)},
                )
                .toList();
      });
    }
  }

  Future<void> _toggleSchedule(String key, bool isActive) async {
    await _ref.child(key).update({"isActive": isActive});
    _loadSchedules(); // Refresh list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Jadwal"),
        backgroundColor: Colors.blueAccent,
      ),
      body:
          _schedules.isEmpty
              ? const Center(child: Text("Belum ada jadwal."))
              : ListView.builder(
                itemCount: _schedules.length,
                itemBuilder: (context, index) {
                  final schedule = _schedules[index];
                  return ListTile(
                    title: Text(schedule['name'] ?? 'Jadwal Tanpa Nama'),
                    subtitle: Text("Waktu: ${schedule['time_start']}"),
                    trailing: Switch(
                      value: schedule['isActive'] ?? true,
                      onChanged: (value) {
                        _toggleSchedule(schedule['key'], value);
                      },
                    ),
                  );
                },
              ),
    );
  }
}
