import 'package:flutter/material.dart';

class JadwalMusikScreen extends StatefulWidget {
  const JadwalMusikScreen({Key? key}) : super(key: key);

  @override
  _JadwalMusikScreenState createState() => _JadwalMusikScreenState();
}

class _JadwalMusikScreenState extends State<JadwalMusikScreen> {
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  String? selectedCategory;
  String? selectedMusic;

  final List<String> categories = ["Kategori 1", "Kategori 2", "Kategori 3"];

  final Map<String, List<String>> musicList = {
    "Kategori 1": ["Lagu 1", "Lagu 2"],
    "Kategori 2": ["Lagu 3", "Lagu 4"],
    "Kategori 3": ["Lagu 5", "Lagu 6"],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Buat Jadwal Musik"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              onChanged: (value) {
                setState(() => selectedCategory = value);
              },
              decoration: const InputDecoration(
                labelText: 'Pilih Kategori Musik',
              ),
            ),
            const SizedBox(height: 16),
            if (selectedCategory != null)
              DropdownButtonFormField<String>(
                value: selectedMusic,
                items:
                    (musicList[selectedCategory] ?? []).map((music) {
                      return DropdownMenuItem(value: music, child: Text(music));
                    }).toList(),
                onChanged: (value) => setState(() => selectedMusic = value),
                decoration: const InputDecoration(labelText: 'Pilih Musik'),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(labelText: 'Waktu (HH:MM)'),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(labelText: 'Durasi (Menit)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Simpan Jadwal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
