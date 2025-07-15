import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:soundnest/service/music_player_service.dart';

final MusicPlayerService musicPlayerService = MusicPlayerService();

class HajiScreen extends StatefulWidget {
  final String categoryPath;
  final String categoryName;
  final bool selectMode;

  const HajiScreen({
    super.key,
    required this.categoryPath,
    required this.categoryName,
    this.selectMode = false,
  });

  @override
  _HajiScreenState createState() => _HajiScreenState();
}

class _HajiScreenState extends State<HajiScreen> {
  late DatabaseReference databaseRef;
  List<Map<String, dynamic>> musicList = [];
  bool isLoading = true;
  int currentIndex = -1;

  @override
  void initState() {
    super.initState();
    print('HajiScreen init - selectMode: ${widget.selectMode}');
    databaseRef = FirebaseDatabase.instance.ref(widget.categoryPath);
    fetchMusicData();
  }

  Future<void> fetchMusicData() async {
    try {
      final snapshot = await databaseRef.get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          musicList = data.entries.map((e) {
            final value = e.value as Map<dynamic, dynamic>;
            return {
              'title': value['title'] ?? 'Tidak ada judul',
              'fileId': value['fileId'] ?? '',
            };
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        print('⚠ Data di path ${widget.categoryPath} tidak ditemukan di database.');
      }
    } catch (e) {
      setState(() => isLoading = false);
      print('❌ Gagal mengambil data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    }
  }

  void togglePlay(int index) async {
    final fileId = musicList[index]['fileId'];
    try {
      if (musicPlayerService.isPlaying &&
          musicPlayerService.currentFileId == fileId) {
        await musicPlayerService.pauseMusic();
        setState(() {
          currentIndex = -1;
        });
      } else {
        print('▶ Memutar fileId: $fileId');
        await musicPlayerService.playFromFileId(
          fileId,
          title: musicList[index]['title'],
          category: widget.categoryName,
        );
        setState(() {
          currentIndex = index;
        });
      }
    } catch (e) {
      print('❌ Gagal memutar audio (fileId: $fileId): $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memutar audio: $e')),
      );
    }
  }

  void _showAddSongDialog() {
    final titleController = TextEditingController();
    final fileIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Musik Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'Judul Audio',
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
                  final nextKey = 'file_${musicList.length + 1}';
                  await databaseRef.child(nextKey).set({
                    'title': title,
                    'fileId': fileId,
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Audio "$title" berhasil ditambahkan')),
                  );
                  await fetchMusicData(); // Refresh data setelah menambahkan
                } catch (e) {
                  print('❌ Gagal menambahkan audio: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menambahkan audio: $e')),
                  );
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
                  "Manasik Haji",
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
                    tooltip: 'Tambah Audio',
                    onPressed: _showAddSongDialog,
                  ),
                ],
              ),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : musicList.isEmpty
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
                            itemCount: musicList.length,
                            separatorBuilder: (context, index) => const Divider(
                              color: Colors.white30,
                              thickness: 0.5,
                              height: 0.5,
                            ),
                            itemBuilder: (context, index) {
                              final music = musicList[index];
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
                                  onTap: () {
                                    if (widget.selectMode) {
                                      Navigator.pop(context, {
                                        'title': music['title'],
                                        'fileId': music['fileId'],
                                        'category': widget.categoryName,
                                      });
                                    } else {
                                      togglePlay(index);
                                    }
                                  },
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