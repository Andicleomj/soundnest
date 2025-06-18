import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:soundnest/service/music_player_service.dart';

final MusicPlayerService musicPlayerService = MusicPlayerService();

class AdaptasiScreen extends StatefulWidget {
  final String categoryPath;
  final String categoryName;
  final bool selectMode;
  final bool fromScheduleTab;

  const AdaptasiScreen({
    super.key,
    required this.categoryPath,
    required this.categoryName,
    this.selectMode = false,
    this.fromScheduleTab = false,
  });

  @override
  _AdaptasiScreenState createState() => _AdaptasiScreenState();
}

class _AdaptasiScreenState extends State<AdaptasiScreen> {
  late DatabaseReference databaseRef;
  List<Map<String, dynamic>> adaptasiList = [];
  bool isLoading = true;
  int currentIndex = -1;

  @override
  void initState() {
    super.initState();
    databaseRef = FirebaseDatabase.instance.ref(widget.categoryPath);
    fetchMusicData();
  }

  void fetchMusicData() async {
    final snapshot = await databaseRef.get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      setState(() {
        adaptasiList =
            data.entries.map((e) {
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
      print('Data di path ${widget.categoryPath} tidak ditemukan di database.');
    }
  }

  void togglePlay(int index) async {
    final fileId = adaptasiList[index]['fileId'];

    if (musicPlayerService.isPlaying &&
        musicPlayerService.currentFileId == fileId) {
      await musicPlayerService.pauseMusic();
      setState(() {
        currentIndex = -1;
      });
    } else {
      await musicPlayerService.playFromFileId(
        fileId,
        title: adaptasiList[index]['title'],
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
          "Masa Adaptasi Sekolah",
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
              : adaptasiList.isEmpty
              ? const Center(child: Text('Data musik tidak tersedia.'))
              : ListView.builder(
                itemCount: adaptasiList.length,
                itemBuilder: (context, index) {
                  final music = adaptasiList[index];
                  final isCurrent =
                      musicPlayerService.currentFileId == music['fileId'] &&
                      musicPlayerService.isPlaying;

                  return ListTile(
                    title: Text(music['title']),
                    onTap: () {
                      if (widget.fromScheduleTab) {
                        Navigator.pop(context, {
                          'title': music['title'],
                          'fileId': music['fileId'],
                          'category': widget.categoryName,
                        });
                      } else {
                        togglePlay(index);
                      }
                    },
                    trailing: IconButton(
                      icon: Icon(isCurrent ? Icons.pause : Icons.play_arrow),
                      onPressed: () => togglePlay(index),
                    ),
                  );
                },
              ),
    );
  }
}
