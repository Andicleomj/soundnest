import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
// TODO: Update the import path below to the correct location of musik_screen.dart or create the file if it does not exist.
import 'package:soundnest/screens/home/musik/musik_screen.dart';

class MusikScheduleForm extends StatefulWidget {
  const MusikScheduleForm({super.key});

  @override
  State<MusikScheduleForm> createState() => _MusikScheduleFormState();
}

class _MusikScheduleFormState extends State<MusikScheduleForm> {
  String? selectedCategory;
  String? selectedMusic;
  String? selectedFileId;

  final TextEditingController _durationController = TextEditingController();
  TimeOfDay? selectedTime;
  bool repeatEveryday = false;
  List<String> selectedDays = [];

  final List<String> daysOfWeek = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickMusic() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MusicScreen(selectMode: true),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        selectedCategory = result['category'] as String?;
        selectedMusic = result['title'] as String?;
        selectedFileId = result['file_id'] as String?;
      });
    }
  }

  void _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  void _saveSchedule() async {
    if (selectedMusic == null ||
        selectedFileId == null ||
        selectedCategory == null ||
        selectedTime == null ||
        _durationController.text.isEmpty ||
        int.tryParse(_durationController.text) == null ||
        (!repeatEveryday && selectedDays.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua isian dengan benar')),
      );
      return;
    }

    final waktuFormatted = selectedTime!.format(context);

    final data = {
      'title': selectedMusic,
      'file_id': selectedFileId,
      'category': selectedCategory,
      'waktu': waktuFormatted,
      'durasi': _durationController.text,
      'hari': repeatEveryday ? 'Setiap Hari' : selectedDays,
      'enabled': true,
    };

    await FirebaseDatabase.instance.ref('jadwal_musik').push().set(data);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Jadwal berhasil disimpan')));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Buat Jadwal Musik")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: Text(
                selectedMusic == null
                    ? "Pilih Musik"
                    : "$selectedMusic (${selectedCategory ?? '-'})",
              ),
              trailing: const Icon(Icons.library_music),
              onTap: _pickMusic,
            ),
            const Divider(),
            ListTile(
              title: Text(
                selectedTime == null
                    ? "Pilih Waktu"
                    : "Waktu: ${selectedTime!.format(context)}",
              ),
              trailing: const Icon(Icons.access_time),
              onTap: _pickTime,
            ),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(labelText: "Durasi (menit)"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text("Ulangi Setiap Hari"),
              value: repeatEveryday,
              onChanged: (val) {
                setState(() {
                  repeatEveryday = val;
                  if (val) selectedDays.clear();
                });
              },
            ),
            if (!repeatEveryday)
              Wrap(
                spacing: 8,
                children:
                    daysOfWeek.map((day) {
                      final isSelected = selectedDays.contains(day);
                      return FilterChip(
                        label: Text(day),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() {
                            if (val) {
                              selectedDays.add(day);
                            } else {
                              selectedDays.remove(day);
                            }
                          });
                        },
                      );
                    }).toList(),
              ),
            const SizedBox(height: 20),
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
