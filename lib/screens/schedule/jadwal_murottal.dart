import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Penjadwalan"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BuatJadwalMurottal(),
                    ),
                  ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text("Murottal Al-Qur’an"),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class BuatJadwalMurottal extends StatefulWidget {
  const BuatJadwalMurottal({super.key});

  @override
  _BuatJadwalMurottalState createState() => _BuatJadwalMurottalState();
}

class _BuatJadwalMurottalState extends State<BuatJadwalMurottal> {
  final DatabaseReference _scheduleRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/schedule/manual',
  );

  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  String selectedCategory = "Surah Pendek";
  final List<String> categories = ["Surah Pendek", "Ayat Kursi"];

  void _saveSchedule() async {
    final time = _timeController.text.trim();
    final duration = _durationController.text.trim();

    if (time.isNotEmpty && duration.isNotEmpty) {
      await _scheduleRef.push().set({
        'time_start': time,
        'duration': duration,
        'content': 'Murottal',
        'category': selectedCategory,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jadwal murottal berhasil disimpan.')),
      );

      _timeController.clear();
      _durationController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buat Jadwal Murottal"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items:
                  categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
              onChanged: (value) => setState(() => selectedCategory = value!),
              decoration: const InputDecoration(labelText: 'Kategori Murottal'),
            ),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(labelText: 'Waktu (HH:MM)'),
            ),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(labelText: 'Durasi (Menit)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveSchedule,
              child: const Text('Simpan Jadwal'),
            ),
          ],
        ),
      ),
    );
  }
}
