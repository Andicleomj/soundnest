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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() {
      isLoading = true;
    });

    final manualSnapshot = await _manualRef.get();
    List<Map<String, dynamic>> loadedSchedules = [];

    if (manualSnapshot.exists) {
      final data = manualSnapshot.value;

      // Amanin tipe data agar gak error runtime
      Map<dynamic, dynamic> dataMap;
      if (data is Map<dynamic, dynamic>) {
        dataMap = data;
      } else if (data is List) {
        dataMap = {
          for (int i = 0; i < data.length; i++)
            if (data[i] != null) i: data[i],
        };
      } else {
        dataMap = {};
      }

      print("📦 Jadwal dari Firebase: $dataMap");

      loadedSchedules =
          dataMap.entries.map((entry) {
            try {
              final scheduleRaw = entry.value;
              if (scheduleRaw is! Map) throw Exception("Format jadwal salah");

              final schedule = Map<String, dynamic>.from(scheduleRaw);

              final hariData = schedule['hari'];
              String hari;

              if (hariData is String) {
                hari = hariData;
              } else if (hariData is List) {
                hari = hariData.join(', ');
              } else if (hariData is Map) {
                hari = hariData.values.join(', ');
              } else {
                hari = '-';
              }

              return {
                'key': entry.key,
                'title': schedule['title'] ?? 'Tanpa Judul',
                'category': schedule['category'] ?? '-',
                'hari': hari,
                'waktu': schedule['waktu'] ?? 'Tidak ada waktu',
                'durasi': schedule['durasi']?.toString() ?? '0',
                'enabled': schedule['enabled'] ?? false,
              };
            } catch (e) {
              print("⚠️ Error parsing entry ${entry.key}: $e");
              return {
                'key': entry.key,
                'title': 'Format Tidak Valid',
                'category': '-',
                'hari': '-',
                'waktu': '-',
                'durasi': '0',
                'enabled': false,
              };
            }
          }).toList();

      print("✅ Loaded ${loadedSchedules.length} jadwal.");
    } else {
      print("❌ Data jadwal tidak ditemukan di Firebase");
    }

    setState(() {
      schedules = loadedSchedules;
      isLoading = false;
    });
  }

  Future<void> _toggleSchedule(String key, bool isActive) async {
    try {
      await _manualRef.child(key).update({"enabled": isActive});
      _loadSchedules();
    } catch (e) {
      print("⚠️ Gagal update jadwal $key: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal mengubah status jadwal")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Jadwal Musik"),
        centerTitle: true,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : schedules.isEmpty
              ? const Center(child: Text("Belum ada jadwal"))
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
                          Text("Mulai: ${schedule['waktu']}"),
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
