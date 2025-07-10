import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class MusicPickerScreen extends StatefulWidget {
  final bool multiPick;
  const MusicPickerScreen({super.key, this.multiPick = false});

  @override
  State<MusicPickerScreen> createState() => _MusicPickerScreenState();
}

class _MusicPickerScreenState extends State<MusicPickerScreen> {
  final DatabaseReference categoryRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/music/categories',
  );
  bool isLoading = true;
  Map<String, dynamic> allMusicData = {};
  List<Map<String, String>> selectedItems = [];

  @override
  void initState() {
    super.initState();
    fetchAllMusic();
  }

  Future<void> fetchAllMusic() async {
    final snapshot = await categoryRef.get();
    if (snapshot.exists) {
      final rawData = Map<String, dynamic>.from(snapshot.value as Map);
      Map<String, List<Map<String, dynamic>>> parsedData = {};

      for (final entry in rawData.entries) {
        final categoryData = Map<String, dynamic>.from(entry.value);
        final categoryName = categoryData['nama'] ?? 'Tanpa Nama';
        final files = categoryData['files'] != null
            ? Map<String, dynamic>.from(categoryData['files'])
            : {};

        final musicList = files.entries.map((e) {
          final fileData = Map<String, dynamic>.from(e.value);
          return {
            'title': fileData['title'] ?? 'Judul tidak tersedia',
            'fileId': fileData['fileId'] ?? '',
          };
        }).toList();

        parsedData[categoryName] = musicList;
      }

      setState(() {
        allMusicData = parsedData;
        isLoading = false;
      });
    } else {
      setState(() {
        allMusicData = {};
        isLoading = false;
      });
    }
  }

  bool isItemSelected(String fileId) {
    return selectedItems.any((item) => item['fileId'] == fileId);
  }

  void toggleItemSelection(String category, String title, String fileId) {
    final item = {
      'category': category,
      'title': title,
      'fileId': fileId,
    };

    setState(() {
      if (isItemSelected(fileId)) {
        selectedItems.removeWhere((e) => e['fileId'] == fileId);
      } else {
        selectedItems.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Pilih Musik',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: widget.multiPick
            ? [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    Navigator.pop(context, selectedItems);
                  },
                )
              ]
            : null,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : allMusicData.isEmpty
              ? const Center(child: Text('Tidak ada musik tersedia'))
              : ListView(
                  children: allMusicData.entries.map((entry) {
                    final categoryName = entry.key;
                    final musicList =
                        entry.value as List<Map<String, dynamic>>;

                    return ExpansionTile(
                      title: Text(categoryName),
                      children: musicList.map((music) {
                        final title = music['title'];
                        final fileId = music['fileId'];

                        return ListTile(
                          title: Text(title),
                          trailing: widget.multiPick
                              ? Checkbox(
                                  value: isItemSelected(fileId),
                                  onChanged: (_) {
                                    toggleItemSelection(
                                        categoryName, title, fileId);
                                  },
                                )
                              : null,
                          onTap: () {
                            if (widget.multiPick) {
                              toggleItemSelection(
                                  categoryName, title, fileId);
                            } else {
                              Navigator.pop(context, {
                                'category': categoryName,
                                'title': title,
                                'fileId': fileId,
                              });
                            }
                          },
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
    );
  }
}
