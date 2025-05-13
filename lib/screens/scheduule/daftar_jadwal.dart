import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DaftarJadwal extends StatefulWidget {
  const DaftarJadwal({super.key});

  @override
  State<DaftarJadwal> createState() => _DaftarJadwalState();
}

class _DaftarJadwalState extends State<DaftarJadwal> {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref(
    'devices/devices_01/schedule_001',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Jadwal"),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder(
        stream: _ref.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Terjadi kesalahan saat memuat data."),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data?.snapshot.value;
            if (data == null) {
              return const Center(child: Text("Belum ada jadwal."));
            }

            final schedules = (data as Map<dynamic, dynamic>).values.toList();
            if (schedules.isEmpty) {
              return const Center(child: Text("Belum ada jadwal."));
            }

            return ListView.builder(
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                final schedule = schedules[index];
                return ListTile(
                  title: Text("Jadwal ${index + 1}"),
                  subtitle: Text(
                    "${schedule['day']} - ${schedule['time_start']}",
                  ),
                  trailing: Switch(
                    value: schedule['isActive'] ?? false,
                    onChanged: (value) {
                      _ref.child(schedule['key']).update({'isActive': value});
                    },
                  ),
                );
              },
            );
          }

          return const Center(child: Text("Belum ada jadwal."));
        },
      ),
    );
  }
}
