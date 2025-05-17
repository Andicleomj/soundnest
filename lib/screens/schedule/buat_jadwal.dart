import 'package:flutter/material.dart';
import 'package:soundnest/screens/schedule/jadwal_murottal.dart';
import 'package:soundnest/screens/schedule/jadwal_musik.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final DatabaseReference _musicCategoryRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/musik',
  );
  final DatabaseReference _murottalCategoryRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/murottal',
  );

  List<String> _musicCategories = [];
  List<String> _murottalCategories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final musicSnapshot = await _musicCategoryRef.get();
    final murottalSnapshot = await _murottalCategoryRef.get();

    setState(() {
      if (musicSnapshot.exists && musicSnapshot.value is Map) {
        _musicCategories =
            (musicSnapshot.value as Map).keys.cast<String>().toList();
      }

      if (murottalSnapshot.exists && murottalSnapshot.value is Map) {
        _murottalCategories =
            (murottalSnapshot.value as Map).keys.cast<String>().toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text("Penjadwalan"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildScheduleOption("Jadwal Musik", _musicCategories),
            const SizedBox(height: 10),
            _buildScheduleOption("Jadwal Murottal", _murottalCategories),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleOption(String title, List<String> categories) {
    return GestureDetector(
      onTap: () async {
        final category = await _selectCategory(categories);
        if (category != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => Text(
                    "Buat Jadwal di Kategori: $category",
                  ), // Nanti ganti dengan halaman buat jadwal
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(title),
      ),
    );
  }

  Future<String?> _selectCategory(List<String> categories) async {
    return showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(categories[index]),
              onTap: () => Navigator.pop(context, categories[index]),
            );
          },
        );
      },
    );
  }
}
