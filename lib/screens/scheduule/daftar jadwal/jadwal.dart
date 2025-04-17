import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:soundnest/screens/scheduule/buat%20jadwal/schedule_screen.dart';
import 'list_schedule_screen.dart'; 

class DaftarJadwal extends StatefulWidget {
  const DaftarJadwal({super.key});

  @override
  State<DaftarJadwal> createState() => _DaftarJadwal();
}

class _DaftarJadwal extends State<DaftarJadwal> {
  int selectedHour = 9;
  int selectedMinute = 40;

  final List<int> hours = List.generate(24, (index) => index);
  final List<int> minutes = List.generate(60, (index) => index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Penjadwalan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Waktu Picker
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(20),
            ),
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Jam Picker
                SizedBox(
                  width: 80,
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(initialItem: selectedHour),
                    itemExtent: 32,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedHour = hours[index];
                      });
                    },
                    children: hours
                        .map((hour) => Center(
                              child: Text(
                                hour.toString().padLeft(2, '0'),
                                style: const TextStyle(color: Colors.white, fontSize: 20),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const Text(
                  ':',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                // Menit Picker
                SizedBox(
                  width: 80,
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(initialItem: selectedMinute),
                    itemExtent: 32,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedMinute = minutes[index];
                      });
                    },
                    children: minutes
                        .map((minute) => Center(
                              child: Text(
                                minute.toString().padLeft(2, '0'),
                                style: const TextStyle(color: Colors.white, fontSize: 20),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          // Tombol
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigasi ke ScheduleScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ScheduleScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Buat Penjadwalan",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigasi ke ListScheduleScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ListScheduleScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Daftar Jadwal",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blueAccent,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Penjadwalan',
          ),
        ],
        onTap: (index) {
          // Navigasi jika diperlukan
        },
      ),
    );
  }
}
