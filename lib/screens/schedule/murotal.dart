import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:soundnest/screens/home/murottal/pickmurottal.dart'; // Pastikan file ini ada

class MurottalScheduleForm extends StatefulWidget {
  const MurottalScheduleForm({super.key});

  @override
  State<MurottalScheduleForm> createState() => _MurottalScheduleFormState();
}

class _MurottalScheduleFormState extends State<MurottalScheduleForm> {
  String? selectedCategory;
  String? selectedMurottal;
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

  Future<void> _pickMurottal() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MurottalPickerScreen()),
    );
    //tes
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        selectedCategory = result['category'] as String?;
        selectedMurottal = result['title'] as String?;
        selectedFileId = result['fileId'] as String?;
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
    if (selectedMurottal == null ||
        selectedFileId == null ||
        selectedCategory == null ||
        selectedTime == null ||
        _durationController.text.trim().isEmpty ||
        int.tryParse(_durationController.text.trim()) == null ||
        (!repeatEveryday && selectedDays.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua isian dengan benar')),
      );
      return;
    }

    final waktuFormatted = selectedTime!.format(context);

    final data = {
      'title': selectedMurottal,
      'fileId': selectedFileId,
      'category': selectedCategory,
      'waktu': waktuFormatted,
      'hari': repeatEveryday ? 'Setiap Hari' : selectedDays,
      'enabled': true,
    };

    final databaseRef = FirebaseDatabase.instance.ref();

    // Simpan ke path: /devices/devices_01/schedule/manual_murottal/
    await databaseRef
        .child('devices')
        .child('devices_01')
        .child('schedule')
        .child('manual')
        .push()
        .set(data);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Jadwal berhasil disimpan')));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Buat Jadwal Murottal")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: Text(
                selectedMurottal == null
                    ? "Pilih Murottal"
                    : "$selectedMurottal (${selectedCategory ?? '-'})",
              ),
              trailing: const Icon(Icons.menu_book),
              onTap: _pickMurottal,
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
