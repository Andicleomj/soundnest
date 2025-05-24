import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:soundnest/service/music_player_service.dart'; // sesuaikan path kamu

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

  late final VoidCallback _playerListener;

  @override
  void initState() {
    super.initState();

    databaseRef = FirebaseDatabase.instance.ref(widget.categoryPath);
    fetchMusicData();

    _playerListener = () {
      if (!mounted) return;

      // Jika musik berhenti, update UI agar item yang sedang aktif di-reset
      if (!musicPlayerService.isPlayingNotifier.value) {
        setState(() {
          currentIndex = -1;
        });
      }
    };

    musicPlayerService.isPlayingNotifier.addListener(_playerListener);
  }

  @override
  void dispose() {
    musicPlayerService.isPlayingNotifier.removeListener(_playerListener);
    super.dispose();
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
                'file_id': value['file_id'] ?? '',
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
    final fileId = adaptasiList[index]['file_id'];

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
        title: const Text(
          'Masa Adaptasi Sekolah',
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
              : adaptasiList.isEmpty
              ? const Center(child: Text('Data musik tidak tersedia.'))
              : ListView.builder(
                itemCount: adaptasiList.length,
                itemBuilder: (context, index) {
                  final music = adaptasiList[index];
                  final isCurrent =
                      musicPlayerService.currentFileId == music['file_id'] &&
                      musicPlayerService.isPlaying;

                  return ListTile(
                    title: Text(music['title']),
                    onTap: () {
                      if (widget.fromScheduleTab) {
                        Navigator.pop(context, {
                          'title': music['title'],
                          'file_id': music['file_id'],
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
