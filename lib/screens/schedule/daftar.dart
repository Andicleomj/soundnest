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

  Map<String, bool> playingStatus = {};

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() => isLoading = true);

    final manualSnapshot = await _manualRef.get();
    List<Map<String, dynamic>> loadedSchedules = [];

    if (manualSnapshot.exists) {
      final data = manualSnapshot.value;

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

              playingStatus[entry.key] ??= false;

              return {
                'key': entry.key,
                'title': schedule['title'] ?? 'Tanpa Judul',
                'category': schedule['category'] ?? '-',
                'hari': hari,
                'waktu': schedule['waktu'] ?? 'Tidak ada waktu',
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
                'enabled': false,
              };
            }
          }).toList();
    }

    setState(() {
      schedules = loadedSchedules;
      isLoading = false;
    });
  }

  Future<void> _toggleSchedule(String key, bool isActive) async {
    try {
      setState(() {
        final idx = schedules.indexWhere((s) => s['key'] == key);
        if (idx != -1) schedules[idx]['enabled'] = isActive;
      });

      await _manualRef.child(key).update({"enabled": isActive});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Jadwal berhasil ${isActive ? 'diaktifkan' : 'dinonaktifkan'}',
          ),
        ),
      );
    } catch (e) {
      print("⚠️ Gagal update jadwal $key: $e");
      setState(() {
        final idx = schedules.indexWhere((s) => s['key'] == key);
        if (idx != -1) schedules[idx]['enabled'] = !isActive;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mengubah status jadwal")),
      );
    }
  }

  Future<void> _deleteSchedule(String key) async {
    try {
      await _manualRef.child(key).remove();
      setState(() {
        schedules.removeWhere((s) => s['key'] == key);
        playingStatus.remove(key);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Jadwal berhasil dihapus")));
    } catch (e) {
      print("⚠️ Gagal hapus jadwal $key: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal menghapus jadwal")));
    }
  }

  void _editSchedule(Map<String, dynamic> schedule) {
    showDialog(
      context: context,
      builder: (context) {
        String newTitle = schedule['title'];
        return AlertDialog(
          title: const Text('Edit Jadwal'),
          content: TextFormField(
            initialValue: schedule['title'],
            decoration: const InputDecoration(labelText: 'Judul'),
            onChanged: (val) => newTitle = val,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _manualRef.child(schedule['key']).update({
                    'title': newTitle,
                  });
                  setState(() {
                    final idx = schedules.indexWhere(
                      (s) => s['key'] == schedule['key'],
                    );
                    if (idx != -1) schedules[idx]['title'] = newTitle;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Jadwal berhasil diperbarui")),
                  );
                } catch (e) {
                  print("⚠️ Gagal update jadwal ${schedule['key']}: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Gagal memperbarui jadwal")),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _togglePlayPause(String key) {
    setState(() {
      playingStatus[key] = !(playingStatus[key] ?? false);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(playingStatus[key]! ? "Play musik" : "Pause musik"),
      ),
    );
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
                  final isPlaying = playingStatus[schedule['key']] ?? false;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        "${schedule['title']} (${schedule['category']})",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Hari: ${schedule['hari']}"),
                            Text("Mulai: ${schedule['waktu']}"),
                            Text(
                              "Status: ${schedule['enabled'] ? 'Aktif' : 'Nonaktif'}",
                              style: TextStyle(
                                color:
                                    schedule['enabled']
                                        ? Colors.green
                                        : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch.adaptive(
                              value: schedule['enabled'],
                              onChanged: (bool value) {
                                _toggleSchedule(schedule['key'], value);
                              },
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: Icon(
                                isPlaying
                                    ? Icons.pause_circle
                                    : Icons.play_circle,
                              ),
                              color: isPlaying ? Colors.green : null,
                              onPressed: () {
                                _togglePlayPause(schedule['key']);
                              },
                              tooltip: isPlaying ? 'Pause Musik' : 'Play Musik',
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _editSchedule(schedule);
                              },
                              tooltip: 'Edit Jadwal',
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              color: Colors.red,
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: const Text('Konfirmasi Hapus'),
                                        content: Text(
                                          'Yakin ingin menghapus "${schedule['title']}"?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(context),
                                            child: const Text('Batal'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _deleteSchedule(schedule['key']);
                                            },
                                            child: const Text('Hapus'),
                                          ),
                                        ],
                                      ),
                                );
                              },
                              tooltip: 'Hapus Jadwal',
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
