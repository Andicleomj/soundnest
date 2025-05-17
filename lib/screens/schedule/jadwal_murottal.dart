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
  bool _isLoading = false;

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

  @override
  void dispose() {
    _timeController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _fetchSurahList() async {
    setState(() {
      _isLoading = true;
      surahList = [];
      selectedSurah = null;
    });

    try {
      final path = categoryPaths[selectedCategory];
      if (path == null) return;

      final ref = FirebaseDatabase.instance.ref(path);
      final snapshot = await ref.get();

      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final titles =
            data.entries
                .where(
                  (entry) =>
                      entry.value != null && entry.value['title'] != null,
                )
                .map((entry) => entry.value['title'].toString())
                .toList();

        setState(() {
          surahList = titles;
          selectedSurah = surahList.isNotEmpty ? surahList.first : null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat daftar surah: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSchedule() async {
    // Ambil nilai waktu dan durasi dari controller
    final String time = _timeController.text.trim();
    final String durationText = _durationController.text.trim();
    int? duration = int.tryParse(durationText);

    // Validasi input
    if (time.isEmpty || duration == null || selectedSurah == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua data dengan benar')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final path = categoryPaths[selectedCategory];
      if (path == null) return;

      final ref = FirebaseDatabase.instance.ref(path);
      final snapshot = await ref.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final surahEntry =
            data.entries
                .where((entry) => entry.value['title'] == selectedSurah)
                .toList();

        if (surahEntry.isNotEmpty) {
          final entry = surahEntry.first;
          final fileId = entry.value['file1']?.toString() ?? '';
          final fileKey = entry.key;

          await ScheduleService().saveManualSchedule(
            time,
            duration.toString(),
            selectedCategory,
            selectedSurah!,
            selectedDay,
            '$selectedCategory/files/$fileKey',
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Jadwal berhasil disimpan')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data surah tidak ditemukan')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
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
        child: SingleChildScrollView(
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
                  if (value != null) {
                    setState(() {
                      selectedCategory = value;
                      _fetchSurahList();
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Kategori Murottal',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                value: selectedSurah,
                items:
                    surahList.map((surah) {
                      return DropdownMenuItem(value: surah, child: Text(surah));
                    }).toList(),
                onChanged: (value) => setState(() => selectedSurah = value),
                decoration: const InputDecoration(labelText: 'Pilih Surah'),
                disabledHint:
                    _isLoading
                        ? const Text('Memuat...')
                        : const Text('Tidak ada surah tersedia'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedDay,
                items:
                    daysOfWeek.map((day) {
                      return DropdownMenuItem(value: day, child: Text(day));
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedDay = value);
                  }
                },
                decoration: const InputDecoration(labelText: 'Pilih Hari'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'Waktu (HH:MM)',
                  hintText: 'Contoh: 08:30',
                ),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Durasi (Menit)',
                  hintText: 'Contoh: 30',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveSchedule,
                  child:
                      _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Simpan Jadwal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
