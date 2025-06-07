import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:audioplayers/audioplayers.dart';

class DaftarJadwalScreen extends StatefulWidget {
  const DaftarJadwalScreen({super.key});

  @override
  _DaftarJadwalScreenState createState() => _DaftarJadwalScreenState();
}

class _DaftarJadwalScreenState extends State<DaftarJadwalScreen> {
  final DatabaseReference _manualRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/schedule/manual',
  );
  final DatabaseReference _otomatisRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/schedule/otomatis',
  );

  List<Map<String, dynamic>> schedules = [];
  bool isLoading = true;

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? currentlyPlayingKey; // key dari jadwal yang sedang diputar

  Map<String, bool> playingStatus = {};

  @override
  void initState() {
    super.initState();
    _loadSchedules();
    _audioPlayer.onPlayerComplete.listen((event) {
      // Reset state saat audio selesai
      setState(() {
        currentlyPlayingKey = null;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadSchedules() async {
    setState(() => isLoading = true);

    final manualSnapshot = await _manualRef.get();
    final otomatisSnapshot = await _otomatisRef.get();

    List<Map<String, dynamic>> loadedSchedules = [];

    List<Map<String, dynamic>> parseSnapshot(
      DataSnapshot snapshot,
      String source,
    ) {
      if (!snapshot.exists) return [];

      final data = snapshot.value;
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

      return dataMap.entries.map((entry) {
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

          final key = '$source-${entry.key}';
          playingStatus[key] ??= false;

          return {
            'key': key,
            'rawKey': entry.key,
            'title':
                schedule['title'] ??
                (source == 'otomatis'
                    ? '[Otomatis] ${schedule['category'] ?? 'Tanpa Judul'}'
                    : 'Tanpa Judul'),
            'category': schedule['category'] ?? '-',
            'hari': hari,
            'waktu': schedule['waktu'] ?? 'Tidak ada waktu',
            'enabled': schedule['enabled'] ?? false,
            'source': source,
            'audioUrl':
                schedule['audioUrl'] ??
                (schedule['fileId'] != null &&
                        (schedule['fileId'] as String).isNotEmpty
                    ? 'https://docs.google.com/uc?export=download&id=${schedule['fileId']}'
                    : ''),
          };
        } catch (e) {
          print("⚠️ Error parsing entry ${entry.key} di $source: $e");
          return {
            'key': '$source-${entry.key}',
            'rawKey': entry.key,
            'title': 'Format Tidak Valid',
            'category': '-',
            'hari': '-',
            'waktu': '-',
            'enabled': false,
            'source': source,
            'audioUrl': '',
          };
        }
      }).toList();
    }

    loadedSchedules.addAll(parseSnapshot(manualSnapshot, 'manual'));
    loadedSchedules.addAll(parseSnapshot(otomatisSnapshot, 'otomatis'));

    setState(() {
      schedules = loadedSchedules;
      isLoading = false;
    });
  }

  DatabaseReference _getRefBySource(String source) {
    switch (source) {
      case 'manual':
        return _manualRef;
      case 'otomatis':
        return _otomatisRef;
      default:
        throw Exception('Unknown source: $source');
    }
  }

  Future<void> _toggleSchedule(String key, bool isActive) async {
    try {
      final idx = schedules.indexWhere((s) => s['key'] == key);
      if (idx == -1) return;

      final schedule = schedules[idx];
      final ref = _getRefBySource(schedule['source']);

      setState(() {
        schedules[idx]['enabled'] = isActive;
      });

      await ref.child(schedule['rawKey']).update({"enabled": isActive});

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
      final idx = schedules.indexWhere((s) => s['key'] == key);
      if (idx == -1) return;

      final schedule = schedules[idx];
      final ref = _getRefBySource(schedule['source']);

      await ref.child(schedule['rawKey']).remove();

      setState(() {
        schedules.removeAt(idx);
        if (currentlyPlayingKey == key) currentlyPlayingKey = null;
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
        String newHari = schedule['hari'];
        String newWaktu = schedule['waktu'];

        return AlertDialog(
          title: const Text('Edit Jadwal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: newHari,
                decoration: const InputDecoration(
                  labelText: 'Hari (pisah koma jika banyak)',
                ),
                onChanged: (val) => newHari = val,
              ),
              TextFormField(
                initialValue: newWaktu,
                decoration: const InputDecoration(
                  labelText: 'Waktu (misal: 14:00)',
                ),
                onChanged: (val) => newWaktu = val,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final ref = _getRefBySource(schedule['source']);

                  final hariList =
                      newHari.split(',').map((e) => e.trim()).toList();

                  await ref.child(schedule['rawKey']).update({
                    'hari': hariList,
                    'waktu': newWaktu,
                  });

                  final idx = schedules.indexWhere(
                    (s) => s['key'] == schedule['key'],
                  );
                  if (idx != -1) {
                    setState(() {
                      schedules[idx]['hari'] = newHari;
                      schedules[idx]['waktu'] = newWaktu;
                    });
                  }

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

  Future<void> _togglePlayPause(String key, String audioUrl) async {
    if (currentlyPlayingKey == key) {
      await _audioPlayer.pause();
      setState(() {
        currentlyPlayingKey = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Pause musik")));
    } else {
      if (audioUrl.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Audio URL kosong")));
        return;
      }

      try {
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(audioUrl));
        setState(() {
          currentlyPlayingKey = key;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Play musik")));
      } catch (e) {
        print("⚠️ Error play audio $key: $e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Gagal memutar audio")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: const Text(
          "Daftar Jadwal",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 164, 214, 255),
              Color.fromARGB(255, 164, 214, 255),
            ],
          ),
        ),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/cloud.jpg'),
              fit: BoxFit.fitWidth,
            ),
          ),
          child:
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : schedules.isEmpty
                  ? const Center(child: Text("Belum ada jadwal"))
                  : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: schedules.length,
                    itemBuilder: (context, index) {
                      final schedule = schedules[index];
                      final isPlaying = currentlyPlayingKey == schedule['key'];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          height: 150,
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${schedule['title']} (${schedule['category']})",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: null,
                                      overflow: TextOverflow.visible,
                                    ),
                                    const SizedBox(height: 4),
                                    ...[
                                          "Hari: ${schedule['hari']}",
                                          "Mulai: ${schedule['waktu']}",
                                          "Sumber: ${schedule['source'].toString().capitalize()}",
                                        ]
                                        .map(
                                          (text) => Text(
                                            text,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 120,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Switch.adaptive(
                                          value: schedule['enabled'],
                                          onChanged: (bool value) {
                                            _toggleSchedule(
                                              schedule['key'],
                                              value,
                                            );
                                          },
                                          activeColor: Colors.white,
                                          activeTrackColor: Colors.blue[200],
                                          inactiveThumbColor: Colors.grey,
                                          inactiveTrackColor: Colors.grey[400],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                          tooltip: "Edit Jadwal",
                                          onPressed:
                                              () => _editSchedule(schedule),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          tooltip: "Hapus Jadwal",
                                          onPressed:
                                              () => _deleteSchedule(
                                                schedule['key'],
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ),
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
