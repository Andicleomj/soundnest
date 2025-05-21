import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class MusicPickerScreen extends StatefulWidget {
  const MusicPickerScreen({super.key});

  @override
  State<MusicPickerScreen> createState() => _MusicPickerScreenState();
}

class _MusicPickerScreenState extends State<MusicPickerScreen> {
  final DatabaseReference categoryRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/music/categories',
  );
  bool isLoading = true;
  Map<String, dynamic> allMusicData =
      {}; // key: nama kategori, value: list of music

  @override
  void initState() {
    super.initState();
    fetchAllMusic();
  }

  Future<void> fetchAllMusic() async {
    final snapshot = await categoryRef.get();
    if (snapshot.exists) {
      print("Snapshot value: ${snapshot.value}"); // Debug
      final rawData = Map<String, dynamic>.from(snapshot.value as Map);
      Map<String, List<Map<String, dynamic>>> parsedData = {};

      for (final entry in rawData.entries) {
        final categoryData = Map<String, dynamic>.from(entry.value);
        final categoryName = categoryData['nama'] ?? 'Tanpa Nama';
        final files =
            categoryData['files'] != null
                ? Map<String, dynamic>.from(categoryData['files'])
                : {};

        final musicList =
            files.entries.map((e) {
              final fileData = Map<String, dynamic>.from(e.value);
              return {
                'title': fileData['title'] ?? 'Judul tidak tersedia',
                'file_id': fileData['file_id'] ?? '',
              };
            }).toList();

        parsedData[categoryName] = musicList;
      }

      setState(() {
        allMusicData = parsedData;
        isLoading = false;
      });
    } else {
      print('Snapshot tidak ditemukan');
      setState(() {
        allMusicData = {};
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Musik')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : allMusicData.isEmpty
              ? const Center(child: Text('Tidak ada musik tersedia'))
              : ListView(
                children:
                    allMusicData.entries.map((entry) {
                      final categoryName = entry.key;
                      final musicList =
                          entry.value as List<Map<String, dynamic>>;

                      return ExpansionTile(
                        title: Text(categoryName),
                        children:
                            musicList.map((music) {
                              final title = music['title'];
                              final fileId = music['file_id'];

                              return ListTile(
                                title: Text(title),
                                onTap: () {
                                  Navigator.pop(context, {
                                    'category': categoryName,
                                    'title': title,
                                    'file_id': fileId,
                                  });
                                },
                              );
                            }).toList(),
                      );
                    }).toList(),
              ),
    );
  }
}
