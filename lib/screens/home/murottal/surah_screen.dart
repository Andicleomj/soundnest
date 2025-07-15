import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:soundnest/service/music_player_service.dart';

final MusicPlayerService musicPlayerService = MusicPlayerService();

class SurahScreen extends StatefulWidget {
  final String categoryPath;
  final String categoryName;

  const SurahScreen({
    super.key,
    required this.categoryPath,
    required this.categoryName,
    required String categoryId,
  });

  @override
  _SurahScreenState createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen> {
  late DatabaseReference databaseRef;
  List<Map<String, dynamic>> surahList = [];
  bool isLoading = true;
  int currentIndex = -1;

  @override
  void initState() {
    super.initState();
    databaseRef = FirebaseDatabase.instance.ref(widget.categoryPath);
    fetchSurahData();
  }

  Future<void> fetchSurahData() async {
    final snapshot = await databaseRef.get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      setState(() {
        surahList = data.entries.map((entry) {
          final value = entry.value as Map<dynamic, dynamic>;
          return {
            'title': value['title'] ?? 'Tanpa Judul',
            'fileId': value['fileId'] ?? '',
          };
        }).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      debugPrint('Data tidak ditemukan di path: ${widget.categoryPath}');
    }
  }

  void togglePlay(int index) async {
    final fileId = surahList[index]['fileId'];

    try {
      if (musicPlayerService.isPlaying &&
          musicPlayerService.currentFileId == fileId) {
        await musicPlayerService.pauseMusic();
        setState(() {
          currentIndex = -1;
        });
      } else {
        await musicPlayerService.playFromFileId(
          fileId,
          title: surahList[index]['title'],
          category: widget.categoryName,
        );
        setState(() {
          currentIndex = index;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memutar audio: $e')),
      );
      debugPrint('❌ Gagal memutar fileId: $fileId, error: $e');
    }
  }

  void _showAddSongDialog() {
    final titleController = TextEditingController();
    final fileIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Surah Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'Judul Surah',
                labelText: 'Judul',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: fileIdController,
              decoration: const InputDecoration(
                hintText: 'Google Drive File ID',
                labelText: 'File ID',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final fileId = fileIdController.text.trim();

              if (title.isNotEmpty && fileId.isNotEmpty) {
                try {
                  final nextKey = 'file_${surahList.length + 1}';
                  await databaseRef.child(nextKey).set({
                    'title': title,
                    'fileId': fileId,
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Surah "$title" berhasil ditambahkan')),
                  );
                  await fetchSurahData(); // Refresh data setelah menambahkan
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menambahkan surah: $e')),
                  );
                  debugPrint('❌ Gagal menambahkan surah: $e');
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Judul dan File ID harus diisi')),
                );
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  "Surah Pendek",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    tooltip: 'Tambah Surah',
                    onPressed: _showAddSongDialog,
                  ),
                ],
              ),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : surahList.isEmpty
                        ? const Center(
                            child: Text(
                              'Data musik tidak tersedia.',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 4,
                            ),
                            itemCount: surahList.length,
                            separatorBuilder: (context, index) => const Divider(
                              color: Colors.white30,
                              thickness: 0.5,
                              height: 0.5,
                            ),
                            itemBuilder: (context, index) {
                              final music = surahList[index];
                              final isCurrent =
                                  musicPlayerService.currentFileId ==
                                      music['fileId'] &&
                                  musicPlayerService.isPlaying;

                              return Card(
                                elevation: 1,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 2,
                                  horizontal: 4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                color: isCurrent
                                    ? Colors.lightBlue[50]!.withOpacity(0.5)
                                    : Colors.white.withOpacity(0.9),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(8),
                                  leading: const Icon(
                                    Icons.music_note,
                                    color: Colors.blueAccent,
                                    size: 24,
                                  ),
                                  title: Text(
                                    music['title'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isCurrent
                                          ? Colors.blueAccent
                                          : Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      isCurrent ? Icons.pause : Icons.play_arrow,
                                      color: isCurrent
                                          ? Colors.blueAccent
                                          : Colors.black54,
                                      size: 24,
                                    ),
                                    onPressed: () => togglePlay(index),
                                  ),
                                  onTap: () => togglePlay(index),
                                  splashColor: Colors.blueAccent.withOpacity(0.3),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}