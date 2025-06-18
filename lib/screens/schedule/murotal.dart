import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:soundnest/screens/home/murottal/pickmurottal.dart';

class MurottalScheduleForm extends StatefulWidget {
  const MurottalScheduleForm({super.key});

  @override
  State<MurottalScheduleForm> createState() => _MurottalScheduleFormState();
}

class _MurottalScheduleFormState extends State<MurottalScheduleForm> {
  List<Map<String, dynamic>> selectedMurottalList = [];
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool repeatEveryday = false;
  List<String> selectedDays = [];

  final List<String> daysOfWeek = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
  ];

  Future<void> _pickMurottal() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MurottalPickerScreen()),
    );

    if (result != null && result is List) {
      setState(() {
        selectedMurottalList = List<Map<String, dynamic>>.from(result);
      });
    }
  }

  void _pickTime({required bool isStart}) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        if (isStart) {
          startTime = time;
        } else {
          endTime = time;
        }
      });
    }
  }

  void _saveSchedule() async {
    if (selectedMurottalList.isEmpty || startTime == null || endTime == null ||
        (!repeatEveryday && selectedDays.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua isian dengan benar')),
      );
      return;
    }

    final startFormatted = startTime!.format(context);
    final endFormatted = endTime!.format(context);

    final data = {
      'murottalList': selectedMurottalList,
      'startTime': startFormatted,
      'endTime': endFormatted,
      'hari': repeatEveryday ? 'Setiap Hari' : selectedDays,
      'enabled': true,
    };

    final databaseRef = FirebaseDatabase.instance.ref();

    await databaseRef
        .child('devices')
        .child('devices_01')
        .child('schedule')
        .child('manual')
        .push()
        .set(data);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Jadwal berhasil disimpan')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Jadwal Murottal"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: Text(
                selectedMurottalList.isEmpty
                    ? "Pilih Murottal"
                    : selectedMurottalList.map((e) => e['title']).join(', '),
              ),
              trailing: const Icon(Icons.menu_book),
              onTap: _pickMurottal,
            ),
            ListTile(
              title: Text(
                startTime == null
                    ? "Pilih Jam Mulai"
                    : "Mulai: ${startTime!.format(context)}",
              ),
              trailing: const Icon(Icons.access_time),
              onTap: () => _pickTime(isStart: true),
            ),
            ListTile(
              title: Text(
                endTime == null
                    ? "Pilih Jam Selesai"
                    : "Selesai: ${endTime!.format(context)}",
              ),
              trailing: const Icon(Icons.access_time),
              onTap: () => _pickTime(isStart: false),
            ),
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
                children: daysOfWeek.map((day) {
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
