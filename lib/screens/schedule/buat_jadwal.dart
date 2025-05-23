import 'package:flutter/material.dart';
import 'package:soundnest/screens/schedule/murotal.dart';
import 'package:soundnest/screens/schedule/musik.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  void _navigateToMusik(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MusikScheduleForm()),
    );
  }

  void _navigateToMurottal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MurottalScheduleForm()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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
            InkWell(
              onTap: () => _navigateToMusik(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.zero,
                ),
                child: const Text("Jadwal Musik"),
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () => _navigateToMurottal(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.zero,
                ),
                child: const Text("Jadwal Murottal"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
