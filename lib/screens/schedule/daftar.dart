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
  final DatabaseReference _autoRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/schedule/otomatis',
  );
  List<Map<String, dynamic>> schedules = [];

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    final manualSnapshot = await _manualRef.get();
    final autoSnapshot = await _autoRef.get();

    List<Map<String, dynamic>> allSchedules = [];

    if (manualSnapshot.exists) {
      allSchedules.addAll(_parseSchedules(manualSnapshot));
    }

    if (autoSnapshot.exists) {
      allSchedules.addAll(_parseSchedules(autoSnapshot));
    }

    setState(() {
      schedules = allSchedules;
    });
  }

  List<Map<String, dynamic>> _parseSchedules(DataSnapshot snapshot) {
    final data = snapshot.value as Map<dynamic, dynamic>;
    return data.entries.map((entry) {
      return {
        "key": entry.key,
        ...(entry.value as Map<dynamic, dynamic>).cast<String, dynamic>(),
      };
    }).toList();
  }

  void _toggleSchedule(String key, bool isActive) async {
    await _manualRef.child(key).update({"isActive": isActive});
    await _autoRef.child(key).update({"isActive": isActive});
    _loadSchedules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Jadwal"), centerTitle: true),
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
                        "${schedule['category']} - ${schedule['surah'] ?? 'No Title'}",
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Hari: ${schedule['day'] ?? '-'}"),
                          Text("Waktu: ${schedule['time_start'] ?? '-'}"),
                          Text("Durasi: ${schedule['duration'] ?? '-'} menit"),
                        ],
                      ),
                      trailing: Switch(
                        value: schedule['isActive'] ?? false,
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
