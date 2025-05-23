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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFB2EBF2), // Biru muda
              Color(0xFFE1F5FE), // Biru sangat muda
            ],
          ),
          image: DecorationImage(
            image: AssetImage('assets/icons/kids.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _navigateToMusik(context),
                  child: Container(
                    height: 100,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 106, 161, 255),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Jadwal Musik",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: InkWell(
                  onTap: () => _navigateToMurottal(context),
                  child: Container(
                    height: 100,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 106, 161, 255),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Jadwal Murottal",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
