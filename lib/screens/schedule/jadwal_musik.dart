import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class BuatJadwalMusik extends StatefulWidget {
  const BuatJadwalMusik({super.key});

  @override
  _BuatJadwalMusikState createState() => _BuatJadwalMusikState();
}

class _BuatJadwalMusikState extends State<BuatJadwalMusik> {
  final DatabaseReference _scheduleRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/schedule/manual',
  );

  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  String? _selectedContent;

  Future<void> _saveSchedule() async {
    if (_timeController.text.isEmpty ||
        _durationController.text.isEmpty ||
        _selectedContent == null)
      return;

    await _scheduleRef.push().set({
      'time_start': _timeController.text,
      'duration': _durationController.text,
      'content': _selectedContent,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Jadwal berhasil disimpan.')));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Jadwal Musik')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(
                labelText: 'Waktu Mulai (HH:MM)',
              ),
            ),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(labelText: 'Durasi (menit)'),
              keyboardType: TextInputType.number,
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
