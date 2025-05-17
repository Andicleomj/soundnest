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
  String selectedDay = "Senin";
  List<String> surahList = [];

  final Map<String, String> categoryPaths = {
    "Surah Pendek": 'devices/devices_01/murottal/categories/kategori_2/files',
    "Ayat Kursi": 'devices/devices_01/murottal/categories/kategori_1/files',
  };

  final List<String> daysOfWeek = [
    "Senin",
    "Selasa",
    "Rabu",
    "Kamis",
    "Jumat",
    "Sabtu",
    "Minggu",
  ];

  @override
  void initState() {
    super.initState();
    _fetchSurahList();
  }

  void _fetchSurahList() async {
    setState(() {
      surahList = [];
      selectedSurah = null;
    });

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

  // baru
  void _saveSchedule() async {
    print("📝 Menyimpan jadwal...");
    final time = _timeController.text.trim();
    final duration = _durationController.text.trim();

    if (time.isEmpty || duration.isEmpty || selectedSurah == null) {
      print("❌ Input tidak lengkap.");
      return;
    }

    final path = categoryPaths[selectedCategory];
    final ref = FirebaseDatabase.instance.ref(path);
    final snapshot = await ref.get();
    final data = Map<String, dynamic>.from(snapshot.value as Map);

    final selectedAudio = data.values.firstWhere(
      (e) => e['title'] == selectedSurah,
      orElse: () => null,
    );

    if (selectedAudio == null) {
      print("❌ Audio tidak ditemukan.");
      return;
    }

    final audioUrl = "http://localhost:3000/drive/${selectedAudio['fileId']}";
    print("✅ Audio URL: $audioUrl");

    await ScheduleService().saveManualSchedule(
      time,
      duration,
      "$selectedCategory - $selectedSurah",
      selectedDay,
      audioUrl,
    );

    print("✅ Jadwal murottal berhasil disimpan.");
    _timeController.clear();
    _durationController.clear();
    setState(() => selectedSurah = null);
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                setState(() {
                  selectedCategory = value!;
                  _fetchSurahList();
                });
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
            DropdownButtonFormField<String>(
              value: selectedDay,
              items:
                  daysOfWeek.map((day) {
                    return DropdownMenuItem(value: day, child: Text(day));
                  }).toList(),
              onChanged: (value) => setState(() => selectedDay = value!),
              decoration: const InputDecoration(labelText: 'Pilih Hari'),
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
                onPressed: _saveSchedule,
                child: const Text('Simpan Jadwal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
