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
  List<Map<String, String>> surahList = [];

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
        surahList =
            data.values
                .where(
                  (e) =>
                      e is Map &&
                      e.containsKey('title') &&
                      e.containsKey('fileId'),
                )
                .map<Map<String, String>>(
                  (e) => {
                    'title': e['title'].toString(),
                    'fileId': e['fileId'].toString(),
                  },
                )
                .toList();
        selectedSurah = surahList.isNotEmpty ? surahList.first['title'] : null;
      });
    }
  }

  void _saveSchedule() async {
    final time = _timeController.text.trim();
    final duration = _durationController.text.trim();

    if (time.isEmpty || duration.isEmpty || selectedSurah == null) return;

    final selectedAudio = surahList.firstWhere(
      (surah) => surah['title'] == selectedSurah,
      orElse: () => {},
    );

    final audioUrl = "http://localhost:3000/drive/${selectedAudio['fileId']}";

    await ScheduleService().saveManualSchedule(
      time,
      duration,
      selectedCategory,
      selectedSurah!,
      selectedDay,
      audioUrl,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Jadwal murottal berhasil disimpan.')),
    );

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
            // Dropdowns and Input Fields
            // Save Button
          ],
        ),
      ),
    );
  }
}
