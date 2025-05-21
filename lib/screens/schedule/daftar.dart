import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DaftarJadwalScreen extends StatefulWidget {
  const DaftarJadwalScreen({super.key});

  @override
  _DaftarJadwalScreenState createState() => _DaftarJadwalScreenState();
}

class _DaftarJadwalScreenState extends State<DaftarJadwalScreen> {
  final DatabaseReference _manualRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/schedule/manual',
  );
  List<Map<String, dynamic>> schedules = [];

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    final manualSnapshot = await _manualRef.get();
    List<Map<String, dynamic>> loadedSchedules = [];

    if (manualSnapshot.exists) {
      final data = manualSnapshot.value as Map<dynamic, dynamic>;
      loadedSchedules =
          data.entries.map((entry) {
            final schedule = Map<String, dynamic>.from(entry.value);
            return {
              'key': entry.key,
              'title': schedule['title'] ?? 'No Title',
              'category': schedule['category'] ?? '-',
              'hari': (schedule['hari'] as Map?)?.values.join(', ') ?? '-',
              'waktu': schedule['waktu'] ?? '-',
              'durasi': schedule['durasi'] ?? '-',
              'enabled': schedule['enabled'] ?? false,
            };
          }).toList();
    }

    setState(() {
      schedules = loadedSchedules;
    });
  }

  void _toggleSchedule(String key, bool isActive) async {
    await _manualRef.child(key).update({"enabled": isActive});
    _loadSchedules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Jadwal Musik"),
        centerTitle: true,
      ),
      body:
          schedules.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  final schedule = schedules[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        "${schedule['title']} (${schedule['category']})",
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Hari: ${schedule['hari']}"),
                          Text("Waktu: ${schedule['waktu']}"),
                          Text("Durasi: ${schedule['durasi']} menit"),
                        ],
                      ),
                      trailing: Switch(
                        value: schedule['enabled'],
                        onChanged: (bool value) {
                          _toggleSchedule(schedule['key'], value);
                        },
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
