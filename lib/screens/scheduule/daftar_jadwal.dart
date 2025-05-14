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

  Map<String, bool> switchStates = {};

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

            final schedules = (data as Map<dynamic, dynamic>).entries.toList();
            if (schedules.isEmpty) {
              return const Center(child: Text("Belum ada jadwal."));
            }

            return ListView.builder(
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                final entry = schedules[index];
                final key = entry.key.toString();
                final schedule = entry.value;

                // Inisialisasi state switch
                switchStates[key] =
                    switchStates[key] ?? (schedule['isActive'] ?? false);

                return ListTile(
                  title: Text("Jadwal ${index + 1}"),
                  subtitle: Text(
                    "${schedule['day']} - ${schedule['time_start']}",
                  ),
                  trailing: Switch(
                    value: switchStates[key] ?? false,
                    onChanged: (value) {
                      setState(() {
                        switchStates[key] = value;
                      });
                      _ref.child(key).update({'isActive': value});
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
