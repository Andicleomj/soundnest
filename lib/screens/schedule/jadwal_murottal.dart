import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:soundnest/service/schedule_service.dart';

class JadwalMurottal extends StatefulWidget {
  const JadwalMurottal({super.key});

  @override
  _JadwalMurottalState createState() => _JadwalMurottalState();
}

class _JadwalMurottalState extends State<JadwalMurottal> {
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  String selectedCategory = "Surah Pendek";
  String? selectedSurah;
  List<String> surahList = [];

  final Map<String, String> categoryPaths = {
    "Surah Pendek": "surah_pendek",
    "Ayat Kursi": "ayat_kursi",
  };

  @override
  void initState() {
    super.initState();
    _fetchSurahList();
  }

  void _fetchSurahList() async {
    final path = categoryPaths[selectedCategory];
    if (path == null) return;

    final ref = FirebaseDatabase.instance.ref(path);
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      setState(() {
        surahList = data.values.map((e) => e['title'].toString()).toList();
        selectedSurah = surahList.isNotEmpty ? surahList.first : null;
      });
    }
  }

  void _saveSchedule() async {
    final time = _timeController.text.trim();
    final duration = _durationController.text.trim();

    if (time.isNotEmpty && duration.isNotEmpty && selectedSurah != null) {
      await ScheduleService().saveManualSchedule(
        time,
        duration,
        "$selectedCategory - $selectedSurah",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jadwal murottal berhasil disimpan.')),
      );

      _timeController.clear();
      _durationController.clear();
      setState(() => selectedSurah = null);
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
                  categoryPaths.keys.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() => selectedCategory = value!);
                _fetchSurahList();
              },
              decoration: const InputDecoration(labelText: 'Kategori Murottal'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedSurah,
              items:
                  surahList.map((surah) {
                    return DropdownMenuItem(value: surah, child: Text(surah));
                  }).toList(),
              onChanged: (value) => setState(() => selectedSurah = value),
              decoration: const InputDecoration(labelText: 'Pilih Surah'),
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
