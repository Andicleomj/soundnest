import 'package:flutter/material.dart';
import 'package:soundnest/screens/home/musik/musik_screen.dart';

class MusikScheduleForm extends StatefulWidget {
  const MusikScheduleForm({Key? key}) : super(key: key);

  @override
  _MusikScheduleFormState createState() => _MusikScheduleFormState();
}

class _MusikScheduleFormState extends State<MusikScheduleForm> {
  String? selectedCategory;
  String? selectedMusic;
  String? selectedDay;

  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  void _pickMusic() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MusicScreen(selectMode: true),
      ),
    );

    if (result != null) {
      setState(() {
        selectedCategory = result['category'];
        selectedMusic = result['music'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Jadwalkan Musik"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: _pickMusic,
              child: Text(
                selectedMusic == null ? "Pilih Musik" : selectedMusic!,
              ),
            ),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(labelText: "Waktu (HH:MM)"),
            ),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(labelText: "Durasi (menit)"),
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Pilih Hari"),
              onChanged: (value) => selectedDay = value,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                print("Kategori: $selectedCategory");
                print("Musik: $selectedMusic");
                print("Waktu: ${_timeController.text}");
                print("Durasi: ${_durationController.text}");
                print("Hari: $selectedDay");
              },
              child: const Text("Simpan Jadwal"),
            ),
          ],
        ),
      ),
    );
  }
}
