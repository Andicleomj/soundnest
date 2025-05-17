import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

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

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  void _saveSchedule() async {
    final time = _timeController.text.trim();
    final duration = _durationController.text.trim();

    if (time.isNotEmpty && duration.isNotEmpty) {
      await _scheduleRef.push().set({
        'time_start': time,
        'duration': duration,
        'content': 'Murottal',
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
            TextField(
              readOnly: true,
              controller: _timeController,
              decoration: const InputDecoration(labelText: 'Waktu (HH:MM)'),
              onTap: () => _selectTime(context),
            ),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(labelText: 'Durasi (Menit)'),
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
