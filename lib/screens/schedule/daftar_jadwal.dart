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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Daftar Jadwal",
        style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                final entry = schedules[index];
                final key = entry.key.toString();
                final schedule = entry.value;

                // Inisialisasi state switch
                switchStates[key] =
                    switchStates[key] ?? (schedule['isActive'] ?? false);

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Jadwal ${index + 1}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              schedule['time_start'] ?? '',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${schedule['type']} : ${schedule['content'] ?? ''}",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Switch(
                          value: switchStates[key] ?? false,
                          onChanged: (value) {
                            setState(() {
                              switchStates[key] = value;
                            });
                            _ref.child(key).update({'isActive': value});
                          },
                        ),
                      ),
                    ],
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
