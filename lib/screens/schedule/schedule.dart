import 'package:flutter/material.dart';
import 'package:soundnest/utils/app_routes.dart';

class Schedule extends StatelessWidget {
  const Schedule({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Penjadwalan",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                children: [
                  // Logo
                  Image.asset(
                    'assets/Logo 1.png',
                    width: 150,
                    height: 150,
                  ),

                  const SizedBox(height: 20),

                  // Judul dan divider
                  const Text(
                    "Atur Jadwal Pemutaran",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Kelola dan pantau jadwal audio Anda dengan mudah",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Divider(thickness: 1, color: Colors.blueAccent),
                  const SizedBox(height: 30),

                  // Tombol grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ActionCard(
                        icon: Icons.add_alarm_rounded,
                        label: "Buat Jadwal",
                        onTap: () => Navigator.pushNamed(context, AppRoutes.schedulescreen),
                      ),
                      _ActionCard(
                        icon: Icons.event_note_rounded,
                        label: "Daftar Jadwal",
                        onTap: () => Navigator.pushNamed(context, AppRoutes.daftarJadwal),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Pesan catatan di bawah
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text(
              "Pastikan semua jadwal telah disimpan dengan benar.",
              style: TextStyle(
                color: Colors.blueGrey,
                fontStyle: FontStyle.italic,
                fontSize: 13.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 36, color: Colors.blueAccent),
                const SizedBox(height: 10),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
