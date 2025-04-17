import 'package:flutter/material.dart';
import 'package:soundnest/utils/app_routes.dart';
import 'package:soundnest/widgets/custom_button.dart';

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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Penjadwalan",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            // Logo di atas
            Image.asset(
              'assets/Logo 1.png',
              width: 180,
              height: 180,
            ),

            // Spacer untuk mendorong tombol ke tengah
            const Spacer(),

            // Bagian tombol di tengah
            Column(
              children: [
                CustomButton(
                  text: "Buat Jadwal",
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.schedulescreen);
                  },
                ),
                const SizedBox(height: 15),
                CustomButton(
                  text: "Daftar Jadwal",
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.daftarJadwal);
                  },
                ),
              ],
            ),

            // Spacer agar tombol tetap di tengah
            const Spacer(),

            // Tombol "Simpan" tetap di bawah
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Fungsi penyimpanan
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    "Simpan",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
