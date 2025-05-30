import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:soundnest/service/music_player_service.dart';

final MusicPlayerService musicPlayerService = MusicPlayerService();

class HariScreen extends StatefulWidget {
  final String categoryPath; // Path lengkap di Firebase Realtime Database
  final String categoryName; // Nama kategori untuk judul AppBar
  final bool selectMode;

  const HariScreen({
    super.key,
    required this.categoryPath,
    required this.categoryName,
    this.selectMode = false,
  });

  @override
  _HariScreenState createState() => _HariScreenState();
}

class _HariScreenState extends State<HariScreen> {
  late DatabaseReference databaseRef;
  List<Map<String, dynamic>> musicList = [];
  bool isLoading = true;
  int currentIndex = -1;

  @override
  void initState() {
    super.initState();
    databaseRef = FirebaseDatabase.instance.ref(
      'devices/devices_01/music/categories/kategori_007/files',
    );
    fetchMusicData();
  }

  void fetchMusicData() async {
    final snapshot = await databaseRef.get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      setState(() {
        musicList =
            data.entries
                .map(
                  (e) => {
                    'title': e.value['title'] ?? 'Tidak ada judul',
                    'fileId': e.value['fileId'] ?? '',
                  },
                )
                .toList();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      print('Data di path ${widget.categoryPath} tidak ditemukan di database.');
    }
  }

  void togglePlay(int index) async {
    final fileId = musicList[index]['fileId'];

    if (musicPlayerService.isPlaying &&
        musicPlayerService.currentFileId == fileId) {
      await musicPlayerService.pauseMusic();
      setState(() {
        currentIndex = -1;
      });
    } else {
      await musicPlayerService.playFromFileId(
        fileId,
        title: musicList[index]['title'],
        category: widget.categoryName,
      );
      setState(() {
        currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Hari Kemerdekaan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : musicList.isEmpty
              ? const Center(child: Text('Data musik tidak tersedia.'))
              : ListView.builder(
                itemCount: musicList.length,
                itemBuilder: (context, index) {
                  final music = musicList[index];
                  final isCurrent =
                      musicPlayerService.currentFileId == music['fileId'] &&
                      musicPlayerService.isPlaying;

                  return ListTile(
                    title: Text(music['title']),
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