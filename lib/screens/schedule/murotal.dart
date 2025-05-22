import 'package:flutter/material.dart';
import 'package:soundnest/screens/home/murottal/murottal_screen.dart';

class MurottalScheduleForm extends StatefulWidget {
  const MurottalScheduleForm({super.key});

  @override
  _MurottalScheduleFormState createState() => _MurottalScheduleFormState();
}

class _MurottalScheduleFormState extends State<MurottalScheduleForm> {
  String? selectedCategory;
  String? selectedMurottal;
  String? selectedDay;

  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  void _pickMurottal() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MurottalScreen()),
    );

    if (result != null) {
      setState(() {
        selectedCategory = result['category'];
        selectedMurottal = result['murottal'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Jadwalkan Murottal"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: _pickMurottal,
              child: Text(
                selectedMurottal == null ? "Pilih Murottal" : selectedMurottal!,
              ),
            ),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(labelText: "Waktu (HH:MM)"),
            ),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(labelText: "Durasi (menit)"),
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Pilih Hari"),
              onChanged: (value) => selectedDay = value,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                print("Kategori: $selectedCategory");
                print("Murottal: $selectedMurottal");
                print("Waktu: ${_timeController.text}");
                print("Durasi: ${_durationController.text}");
                print("Hari: $selectedDay");
              },
              child: const Text("Simpan Jadwal"),
            ),
          ],
        ),
      ),
    );
  }
}
