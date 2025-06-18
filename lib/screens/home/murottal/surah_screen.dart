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
        surahList =
            data.entries.map((entry) {
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
          "Surah Pendek",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : surahList.isEmpty
              ? const Center(child: Text('Data musik tidak tersedia.'))
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