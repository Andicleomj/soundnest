import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

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
      final autoSnapshot =
          await _autoRef.child(_getDayName(DateTime.now())).get();

      if (!mounted) return; // Tambahkan pengecekan mounted sebelum setState

      setState(() {
        _manualSchedules =
            manualSnapshot.exists && manualSnapshot.value is Map
                ? Map<String, dynamic>.from(manualSnapshot.value as Map).entries
                    .map((entry) => Map<String, dynamic>.from(entry.value))
                    .toList()
                : [];

        _autoSchedules =
            autoSnapshot.exists && autoSnapshot.value is Map
                ? [Map<String, dynamic>.from(autoSnapshot.value as Map)]
                : [];

        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print("Error loading schedules: $e");
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
      appBar: AppBar(title: const Text("Penjadwalan Musik"), centerTitle: true),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
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
                        : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _manualSchedules.length,
                          itemBuilder: (context, index) {
                            final schedule = _manualSchedules[index];
                            return ListTile(
                              title: Text(
                                "${schedule['time_start'] ?? 'Waktu tidak tersedia'} - ${schedule['time_end'] ?? 'Waktu tidak tersedia'}",
                              ),
                              subtitle: Text(
                                "Konten: ${schedule['content'] ?? 'Tidak ada konten'}",
                              ),
                            );
                          },
                        ),
                    const SizedBox(height: 16),
                    const Text(
                      "Jadwal Otomatis",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _autoSchedules.isEmpty
                        ? const Text("Tidak ada jadwal otomatis hari ini.")
                        : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _autoSchedules.length,
                          itemBuilder: (context, index) {
                            final schedule = _autoSchedules[index];
                            final content =
                                schedule['content'] is List
                                    ? (schedule['content'] as List)
                                        .map((e) => e.toString())
                                        .join(', ')
                                    : "Tidak ada konten";

                            return ListTile(
                              title: Text(
                                "${schedule['time'] ?? 'Tidak ada waktu'} (Durasi: ${schedule['duration'] ?? 'Tidak ada durasi'})",
                              ),
                              subtitle: Text("Konten: $content"),
                            );
                          },
                        ),
                  ],
                ),
              ),
    );
  }
}
