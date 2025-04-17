import 'package:flutter/material.dart';

class ListScheduleScreen extends StatelessWidget {
  const ListScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy list jadwal (bisa diganti dengan data dari database)
    final List<Map<String, String>> schedules = [
      {'time': '09:40', 'detail': 'Murottal Al-Qur\'an : Al-mulk'},
      {'time': '12:30', 'detail': 'Musik : odong-odong'},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.blueAccent, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, 200, 70)),
          child: const Text(
            "Daftar Jadwal",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black, // akan ditimpa oleh ShaderMask
            ),
          ),
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
      body: Center(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 30),
          itemCount: schedules.length,
          itemBuilder: (context, index) {
            final item = schedules[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEDEDED),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Bagian kiri: Waktu dan Detail Jadwal
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['time'] ?? '',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['detail'] ?? '',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),

                  // Bagian kanan: Tombol Hapus (Tong Sampah)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Fungsi untuk menghapus item bisa ditambahkan disini
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
