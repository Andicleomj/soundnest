import 'package:flutter/material.dart';

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

  final List<String> categories = [
    "Masa Adaptasi Sekolah",
    "Aku Suka Olahraga",
    "My Family",
    "Bumi Planet",
    "Hari Kemerdekaan",
  ];

  final List<String> days = [
    "Senin",
    "Selasa",
    "Rabu",
    "Kamis",
    "Jumat",
    "Sabtu",
    "Minggu",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Jadwalkan Musik")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(labelText: "Pilih Kategori"),
              items:
                  categories
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              onChanged: (value) => setState(() => selectedCategory = value),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(labelText: "Waktu (HH:MM)"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(labelText: "Durasi (menit)"),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedDay,
              decoration: const InputDecoration(labelText: "Pilih Hari"),
              items:
                  days
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              onChanged: (value) => setState(() => selectedDay = value),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                if (selectedCategory != null &&
                    selectedDay != null &&
                    _timeController.text.isNotEmpty &&
                    _durationController.text.isNotEmpty) {
                  // Save schedule logic here
                  print(
                    "Jadwal Disimpan: $selectedCategory - ${_timeController.text} - ${_durationController.text} - $selectedDay",
                  );
                }
              },
              child: const Text("Simpan Jadwal"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timeController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}
