import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:soundnest/service/music_player_service.dart';

final MusicPlayerService musicPlayerService = MusicPlayerService();

class AyatKursi extends StatefulWidget {
  final String categoryPath;
  final String categoryName;

  const AyatKursi({
    super.key,
    required this.categoryPath,
    required this.categoryName,
    required String categoryId,
  });

  @override
  State<AyatKursi> createState() => _AyatKursiState();
}

class _AyatKursiState extends State<AyatKursi> {
  late DatabaseReference databaseRef;
  List<Map<String, dynamic>> surahList = [];
  bool isLoading = true;
  int currentIndex = -1;

  @override
  void initState() {
    super.initState();
    databaseRef = FirebaseDatabase.instance.ref(widget.categoryPath);
    listenToDatabase();
  }

  void listenToDatabase() {
    databaseRef.onValue.listen((event) {
      final snapshot = event.snapshot;
      if (snapshot.exists) {
        try {
          final data = Map<String, dynamic>.from(snapshot.value as Map);
          final List<Map<String, dynamic>> tempList = [];

          data.forEach((key, value) {
            if (value is Map &&
                value.containsKey('title') &&
                value.containsKey('fileId')) {
              tempList.add({
                'title': value['title'],
                'fileId': value['fileId'],
              });
            }
          });

          setState(() {
            surahList = tempList;
            isLoading = false;
          });
        } catch (e) {
          print('❌ Gagal parsing data: $e');
          setState(() => isLoading = false);
        }
      } else {
        print('⚠ Data tidak ditemukan di path: ${widget.categoryPath}');
        setState(() {
          surahList = [];
          isLoading = false;
        });
      }
    });
  }

  void togglePlay(int index) async {
    final fileId = surahList[index]['fileId'];

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
        title: surahList[index]['title'],
        category: widget.categoryName,
      );
      setState(() {
        currentIndex = index;
      });
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
              ),
            ),
            TextField(
              controller: fileIdController,
              decoration: const InputDecoration(
                hintText: 'Google Drive File ID',
                labelText: 'File ID',
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
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menambahkan surah: $e')),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Ayat Kursi",
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : surahList.isEmpty
              ? const Center(child: Text('Data tidak tersedia.'))
              : ListView.builder(
                  itemCount: surahList.length,
                  itemBuilder: (context, index) {
                    final murottal = surahList[index];
                    final isCurrent =
                        musicPlayerService.currentFileId == murottal['fileId'] &&
                        musicPlayerService.isPlaying;

                    return ListTile(
                      title: Text(murottal['title']),
                      trailing: IconButton(
                        icon: Icon(isCurrent ? Icons.pause : Icons.play_arrow),
                        onPressed: () => togglePlay(index),
                      ),
                      onTap: () => togglePlay(index),
                    );
                  },
                ),
    );
  }
}