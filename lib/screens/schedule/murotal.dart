import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:soundnest/screens/home/murottal/pickmurottal.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

 List<Map<String, dynamic>> stars = [
  {'top': 30.0, 'left': 20.0, 'size': 25.0, 'color': Colors.pinkAccent},
  {'top': 60.0, 'left': screenWidth * 0.3, 'size': 20.0, 'color': Colors.lightBlueAccent},
  {'top': 90.0, 'left': screenWidth * 0.65, 'size': 35.0, 'color': Colors.greenAccent},

  {'top': screenHeight * 0.2, 'left': screenWidth * 0.1, 'size': 22.0, 'color': Colors.yellowAccent},
  {'top': screenHeight * 0.22, 'left': screenWidth * 0.75, 'size': 28.0, 'color': Colors.orangeAccent},
  {'top': screenHeight * 0.3, 'left': screenWidth * 0.4, 'size': 60.0, 'color': Colors.blueAccent},

  {'top': screenHeight * 0.4, 'left': screenWidth * 0.15, 'size': 24.0, 'color': Colors.white},
  {'top': screenHeight * 0.45, 'left': screenWidth * 0.7, 'size': 30.0, 'color': Colors.purpleAccent},
  {'top': screenHeight * 0.5, 'left': screenWidth * 0.5, 'size': 40.0, 'color': Colors.pinkAccent},

  {'top': screenHeight * 0.6, 'left': screenWidth * 0.25, 'size': 30.0, 'color': Colors.white},
  {'top': screenHeight * 0.68, 'left': screenWidth * 0.6, 'size': 45.0, 'color': Colors.cyanAccent},
  {'top': screenHeight * 0.72, 'left': screenWidth * 0.15, 'size': 35.0, 'color': Colors.purpleAccent},

  {'top': screenHeight * 0.8, 'left': screenWidth * 0.8, 'size': 50.0, 'color': Colors.greenAccent},
  {'top': screenHeight * 0.85, 'left': screenWidth * 0.4, 'size': 40.0, 'color': Colors.amberAccent},
  {'top': screenHeight * 0.7, 'left': screenWidth * 0.9, 'size': 22.0, 'color': Colors.pinkAccent},
];


 Widget buildStar({required double size, required Color color}) {
  return ShaderMask(
    shaderCallback: (bounds) {
      return RadialGradient(
        colors: [color.withOpacity(0.9), color.withOpacity(0)],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
    },
    blendMode: BlendMode.srcATop,
    child: Icon(
      Icons.star,
      size: size,
      color: Colors.white, // warna dasar sebelum shader diterapkan
    ),
  );
}

    return Scaffold(
       backgroundColor: Colors.white,
         appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Buat Jadwal Murottal",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),

       body: Stack(
      children: [
        // Background gradient
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFDCF1FF),
                Color(0xFFA4D6FF),
                Color(0xFFF2F9FD),
              ],
            ),
          ),
        ),
        // Bintang-bintang
        ...stars.map((pos) => Positioned(
              top: pos['top'],
              left: pos['left'],
              child: buildStar(size: pos['size'], color: pos['color']),
            )),

             Container(
      color: Colors.white.withOpacity(0.2),
    ),

      Padding(
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
              activeColor: Colors.white, // warna thumb saat aktif
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
            OutlinedButton(
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
      ],
       ),
    );
  }
}