import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:soundnest/screens/home/musik/musik_screen.dart';

class MusikScheduleForm extends StatefulWidget {
  final String? title;
  final String? fileId;
  final String? category;

  const MusikScheduleForm({super.key, this.title, this.fileId, this.category});

  @override
  State<MusikScheduleForm> createState() => _MusikScheduleFormState();
}

class _MusikScheduleFormState extends State<MusikScheduleForm> {
  String? selectedCategory;
  String? selectedMusic;
  String? selectedFileId;
  String? selectedDay;

  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.category;
    selectedMusic = widget.title;
    selectedFileId = widget.fileId;
  }

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
        selectedMusic = result['title'];
        selectedFileId = result['file_id'];
      });
    }
  }

  void _saveSchedule() async {
    if (selectedMusic == null ||
        selectedFileId == null ||
        selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih musik terlebih dahulu')),
      );
      return;
    }

    // Simpan ke Firebase Realtime Database
    await FirebaseDatabase.instance.ref('jadwal_musik').push().set({
      'title': selectedMusic,
      'file_id': selectedFileId,
      'category': selectedCategory,
      'waktu': _timeController.text,
      'durasi': _durationController.text,
      'hari': selectedDay,
      'enabled': true,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Jadwal berhasil disimpan')));

    Navigator.pop(context);
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
                selectedMusic == null
                    ? "Pilih Musik"
                    : "$selectedMusic (${selectedCategory ?? '-'})",
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
              onPressed: _saveSchedule,
              child: const Text("Simpan Jadwal"),
            ),
          ],
        ),
      ),
    );
  }
}
