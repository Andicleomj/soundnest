import 'package:flutter/material.dart';
import 'package:soundnest/service/schedule_service.dart';

class DaftarJadwal extends StatefulWidget {
  const DaftarJadwal({super.key});

  @override
  State<DaftarJadwal> createState() => _DaftarJadwalState();
}

class _DaftarJadwalState extends State<DaftarJadwal> {
  final ScheduleService _scheduleService = ScheduleService();

  @override
  void initState() {
    super.initState();
    _scheduleService.start();
  }

  @override
  void dispose() {
    _scheduleService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Jadwal"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _scheduleService.getSchedules(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final schedules = snapshot.data ?? [];
                  if (schedules.isEmpty) {
                    return const Center(child: Text("Tidak ada jadwal."));
                  }

                  return ListView.builder(
                    itemCount: schedules.length,
                    itemBuilder: (context, index) {
                      final schedule = schedules[index];
                      return ListTile(
                        title: Text(schedule["day"] ?? "Unknown"),
                        subtitle: Text("Jam: ${schedule["time_start"] ?? "-"}"),
                      );
                    },
                  );
                },
              ),
            ),
            if (_scheduleService.isAudioPlaying)
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  "Audio sedang diputar...",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
