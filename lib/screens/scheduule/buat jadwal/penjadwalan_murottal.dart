import 'package:flutter/material.dart';
import 'package:soundnest/screens/scheduule/buat%20jadwal/penjadwalan_pengulangan.dart';

class MurottalScreen extends StatelessWidget {
  const MurottalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
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
        title: const Text(
          "Penjadwalan",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PenjadwalanScreen_()),
                );
              },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text("List Murottal Al-Qur’an"),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.home, color: Colors.white),
                Text("Home", style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule, color: Colors.white),
                Text("Penjadwalan", style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
