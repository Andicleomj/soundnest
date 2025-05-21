import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class MusicPickerScreen extends StatefulWidget {
  const MusicPickerScreen({super.key});

  @override
  State<MusicPickerScreen> createState() => _MusicPickerScreenState();
}

class _MusicPickerScreenState extends State<MusicPickerScreen> {
  final DatabaseReference rootRef = FirebaseDatabase.instance.ref('musik');
  bool isLoading = true;
  Map<String, dynamic> allMusicData = {}; // key: kategori, value: Map musik

  @override
  void initState() {
    super.initState();
    fetchAllMusic();
  }

  Future<void> fetchAllMusic() async {
    final snapshot = await rootRef.get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      setState(() {
        allMusicData = data;
        isLoading = false;
      });
    } else {
      setState(() {
        allMusicData = {};
        isLoading = false;
      });
      print('Data musik tidak ditemukan');
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
                    allMusicData.entries.map((categoryEntry) {
                      final category = categoryEntry.key;
                      final musicMap = Map<String, dynamic>.from(
                        categoryEntry.value,
                      );

                      return ExpansionTile(
                        title: Text(category),
                        children:
                            musicMap.entries.map((musicEntry) {
                              final music = Map<String, dynamic>.from(
                                musicEntry.value,
                              );
                              final title =
                                  music['title'] ?? 'Judul tidak tersedia';
                              final fileId = music['file_id'] ?? '';

                              return ListTile(
                                title: Text(title),
                                onTap: () {
                                  Navigator.pop(context, {
                                    'category': category,
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
