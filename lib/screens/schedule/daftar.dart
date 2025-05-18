import 'package:flutter/material.dart';

class DaftarJadwalScreen extends StatelessWidget {
  const DaftarJadwalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Jadwal"), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 10, // Sementara 10, ganti dengan jumlah jadwal dari database
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: const Text("Jadwal Musik/Murottal"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Hari: Senin"),
                  Text("Waktu: 10:00"),
                  Text("Durasi: 30 menit"),
                ],
              ),
              trailing: Switch(
                value: true, // Ganti dengan status aktif/tidak dari database
                onChanged: (bool value) {},
              ),
            ),
          );
        },
      ),
    );
  }
}
