import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:audioplayers/audioplayers.dart';

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
  bool _isLoading = true;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentPlayingId;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    try {
      final manualSnapshot = await _manualRef.get();
      setState(() {
        _manualSchedules =
            manualSnapshot.exists && manualSnapshot.value is Map
                ? (manualSnapshot.value as Map).entries.map((e) {
                  final data = Map<String, dynamic>.from(e.value);
                  return {
                    'id': e.key,
                    'category': data['category'] ?? 'Tanpa Kategori',
                    'content': data['content'] ?? 'Tanpa Konten',
                    'duration': data['duration'] ?? '00:00',
                    'time_start': data['time_start'] ?? 'Tidak ada waktu',
                    'is_active': data['is_active'] ?? false,
                    'audio_url': data['audio_url'] ?? '', // URL Audio
                  };
                }).toList()
                : [];
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading schedules: $e");
    }
  }

  void _toggleScheduleStatus(String id, bool isActive) async {
    await _manualRef.child(id).update({'is_active': isActive});
    setState(() {
      _manualSchedules =
          _manualSchedules.map((schedule) {
            if (schedule['id'] == id) {
              schedule['is_active'] = isActive;
            }
            return schedule;
          }).toList();
    });
  }

  // Fungsi untuk memutar audio
  void _playAudio(String id, String url) async {
    if (_currentPlayingId == id) {
      await _audioPlayer.stop();
      setState(() {
        _currentPlayingId = null;
      });
    } else {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
      setState(() {
        _currentPlayingId = id;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Jadwal Musik & Murottal"),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _manualSchedules.length,
                itemBuilder: (context, index) {
                  final schedule = _manualSchedules[index];
                  return ListTile(
                    title: Text(schedule['category']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Konten: ${schedule['content']}"),
                        Text("Durasi: ${schedule['duration']}"),
                        Text("Mulai: ${schedule['time_start']}"),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tombol Play/Pause
                        IconButton(
                          icon: Icon(
                            _currentPlayingId == schedule['id']
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                          onPressed:
                              schedule['audio_url'].isNotEmpty
                                  ? () => _playAudio(
                                    schedule['id'],
                                    schedule['audio_url'],
                                  )
                                  : null,
                        ),
                        // Switch Aktivasi Jadwal
                        Switch(
                          value: schedule['is_active'],
                          onChanged:
                              (value) =>
                                  _toggleScheduleStatus(schedule['id'], value),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
