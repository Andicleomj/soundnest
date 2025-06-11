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
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Penjadwalan",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 164, 214, 255), // Biru muda
              Color.fromARGB(255, 164, 214, 255), // Biru sangat muda
            ],
          ),
        ),
        child: Container(
          width: double.infinity,
          height: 600, // atur tinggi sesuai kebutuhan
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/kids.jpg'),
              fit: BoxFit.fitWidth, // atau contain, fill, etc
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
                        color: Color.fromARGB(255, 164, 214, 255),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color.fromARGB(255, 115, 166, 255),
                          width: 2,
                        ),
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
                        color: Color.fromARGB(255, 164, 214, 255),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color.fromARGB(255, 115, 166, 255),
                          width: 2,
                        ),
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
      ),
    );
  }
}
