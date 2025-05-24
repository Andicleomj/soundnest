import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:soundnest/screens/home/murottal/pickmurottal.dart'; // Pastikan file ini ada
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';

class MurottalScheduleForm extends StatefulWidget {
  const MurottalScheduleForm({super.key});

  @override
  State<MurottalScheduleForm> createState() => _MurottalScheduleFormState();
}

class _MurottalScheduleFormState extends State<MurottalScheduleForm> {
  String? selectedCategory;
  String? selectedMurottal;
  String? selectedFileId;

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

  Future<void> _pickMurottal() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MurottalPickerScreen()),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        selectedCategory = result['category'] as String?;
        selectedMurottal = result['title'] as String?;
        selectedFileId = result['fileId'] as String?;
      });
    }
  }

  void _pickTime() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TimeOfDay tempSelectedTime = selectedTime ?? TimeOfDay.now();
        DateTime initialTime = DateTime(
          0,
          0,
          0,
          tempSelectedTime.hour,
          tempSelectedTime.minute,
        );

        return AlertDialog(
          title: const Text("Pilih Waktu"),
          content: SizedBox(
            height: 180,
            child: TimePickerSpinner(
              is24HourMode: true,
              normalTextStyle: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
              highlightedTextStyle: const TextStyle(
                fontSize: 24,
                color: Colors.blue,
              ),
              spacing: 40,
              itemHeight: 40,
              isForce2Digits: true,
              time: initialTime,
              onTimeChange: (DateTime time) {
                setState(() {
                  selectedTime = TimeOfDay.fromDateTime(time);
                });
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _saveSchedule() async {
    if (selectedMurottal == null ||
        selectedFileId == null ||
        selectedCategory == null ||
        selectedTime == null ||
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: const Text(
          "Buat Jadwal Murottal",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
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
              trailing: const Icon(
                Icons.menu_book,
                color: Color.fromARGB(255, 81, 177, 255),
              ),
              onTap: _pickMurottal,
            ),
            const Divider(),
            ListTile(
              title: Text(
                selectedTime == null
                    ? "Pilih Waktu"
                    : "Waktu: ${selectedTime!.format(context)}",
              ),
              trailing: const Icon(
                Icons.access_time,
                color: Color.fromARGB(255, 81, 177, 255),
              ),
              onTap: _pickTime,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text("Ulangi Setiap Hari"),
              value: repeatEveryday,
              activeColor: Color.fromARGB(
                255,
                81,
                177,
                255,
              ), // warna thumb saat aktif
              activeTrackColor: Colors.blue[200], // warna track saat aktif
              inactiveThumbColor:
                  Colors.grey[300], // warna thumb saat tidak aktif
              inactiveTrackColor:
                  Colors.grey[400], // warna track saat tidak aktif
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
                        label: Text(
                          day,
                          style: TextStyle(
                            color:
                                isSelected
                                    ? Color.fromARGB(255, 81, 177, 255)
                                    : Colors.black,
                          ),
                        ),
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
              style: OutlinedButton.styleFrom(
                foregroundColor: Color.fromARGB(
                  255,
                  81,
                  177,
                  255,
                ), // Warna teks
                side: const BorderSide(
                  color: Colors.blue,
                ), // Garis pinggir biru
                shape: const StadiumBorder(), // Membuat tombol lonjong
              ),
              child: const Text("Simpan Jadwal"),
            ),
          ],
        ),
      ),
    );
  }
}
