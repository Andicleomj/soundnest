import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
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
  bool _isLoading = true;
  StreamSubscription<DatabaseEvent>? _manualSubscription;

  @override
  void initState() {
    super.initState();
    _setupRealtimeUpdates();
    _loadInitialSchedules();
  }

  void _setupRealtimeUpdates() {
    _manualSubscription = _manualRef.onValue.listen((event) {
      if (mounted) {
        _processSchedules(event.snapshot);
      }
    });
  }

  Future<void> _loadInitialSchedules() async {
    try {
      final manualSnapshot = await _manualRef.get();
      _processSchedules(manualSnapshot);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      _showErrorSnackbar('Gagal memuat jadwal: ${e.toString()}');
    }
  }

  void _processSchedules(DataSnapshot snapshot) {
    if (!mounted) return;

    setState(() {
      _manualSchedules =
          snapshot.exists && snapshot.value is Map
              ? (snapshot.value as Map).entries.map((e) {
                final data = Map<String, dynamic>.from(e.value as Map);
                return {
                  'id': e.key,
                  'category': data['category'] ?? 'Tanpa Kategori',
                  'content': data['content'] ?? 'Tanpa Konten',
                  'duration': data['duration'] ?? '00:00',
                  'time_start': data['time_start'] ?? 'Tidak ada waktu',
                  'is_active': data['is_active'] ?? false,
                };
              }).toList()
              : [];
      _isLoading = false;
    });
  }

  Future<void> _toggleScheduleStatus(String id, bool isActive) async {
    try {
      await _manualRef.child(id).update({'is_active': isActive});
      if (mounted) {
        setState(() {
          _manualSchedules =
              _manualSchedules.map((schedule) {
                if (schedule['id'] == id) {
                  return {...schedule, 'is_active': isActive};
                }
                return schedule;
              }).toList();
        });
      }
    } catch (e) {
      _showErrorSnackbar('Gagal mengupdate status: ${e.toString()}');
    }
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  void dispose() {
    _manualSubscription?.cancel();
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
              : RefreshIndicator(
                onRefresh: _loadInitialSchedules,
                child:
                    _manualSchedules.isEmpty
                        ? const Center(child: Text("Tidak ada jadwal tersedia"))
                        : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _manualSchedules.length,
                          itemBuilder: (context, index) {
                            final schedule = _manualSchedules[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                title: Text(
                                  schedule['category'],
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text("Konten: ${schedule['content']}"),
                                    Text(
                                      "Durasi: ${schedule['duration']} menit",
                                    ),
                                    Text("Mulai: ${schedule['time_start']}"),
                                  ],
                                ),
                                trailing: Switch(
                                  value: schedule['is_active'],
                                  onChanged:
                                      (value) => _toggleScheduleStatus(
                                        schedule['id'],
                                        value,
                                      ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
    );
  }
}
