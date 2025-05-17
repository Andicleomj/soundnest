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
            data.values
                .where((e) => e != null && e['title'] != null)
                .map((e) => e['title'].toString())
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
    final time = _timeController.text.trim();
    final duration = _durationController.text.trim();

    // Validate time format (HH:MM)
    if (!RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(time)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format waktu tidak valid. Gunakan HH:MM'),
        ),
      );
      return;
    }

    // Validate duration is a positive number
    if (duration.isEmpty ||
        int.tryParse(duration) == null ||
        int.parse(duration) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Durasi harus angka positif')),
      );
      return;
    }

    if (selectedSurah == null || selectedSurah!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih surah terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ScheduleService().saveManualSchedule(
        time,
        duration,
        selectedCategory,
        selectedSurah!,
        selectedDay,
        '', // You might want to pass the actual file ID here
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jadwal murottal berhasil disimpan')),
      );

      _timeController.clear();
      _durationController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan jadwal: $e')));
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
                    setState(() => selectedCategory = value);
                    _fetchSurahList();
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
