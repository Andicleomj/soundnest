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
  String? selectedCategory;
  String? selectedSurah;
  List<String> categoryList = [];
  List<String> surahList = [];

  @override
  void initState() {
    super.initState();
    _fetchCategoryList();
  }

  void _fetchCategoryList() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.get();
    print('Data Firebase (Kategori): ${snapshot.value}');

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      setState(() {
        categoryList = data.keys.toList();
        selectedCategory = categoryList.isNotEmpty ? categoryList.first : null;
        if (selectedCategory != null) {
          _fetchSurahList(selectedCategory!);
        }
      });
    } else {
      print("Database kosong atau tidak ditemukan.");
    }
  }

  void _fetchSurahList(String category) async {
    final ref = FirebaseDatabase.instance.ref('$category/files');
    final snapshot = await ref.get();
    print('Data Firebase (Surah - $category): ${snapshot.value}');

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      setState(() {
        surahList = data.keys.toList();
        selectedSurah = surahList.isNotEmpty ? surahList.first : null;
      });
    } else {
      setState(() {
        surahList = [];
        selectedSurah = null;
      });
      print("Tidak ada surah di kategori $category.");
    }
  }

  void _saveSchedule() async {
    final time = _timeController.text.trim();
    final duration = _durationController.text.trim();

    if (time.isNotEmpty &&
        duration.isNotEmpty &&
        selectedSurah != null &&
        selectedCategory != null) {
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
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lengkapi semua field.')));
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
                  categoryList.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                  selectedSurah = null;
                  surahList = [];
                });
                if (value != null) _fetchSurahList(value);
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
            const SizedBox(height: 16),
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
