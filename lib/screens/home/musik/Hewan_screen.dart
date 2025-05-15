import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:audioplayers/audioplayers.dart';

class HewanScreen extends StatefulWidget {
  final String categoryPath; // Path lengkap di Firebase Realtime Database
  final String categoryName; // Nama kategori untuk judul AppBar

  const HewanScreen({
    Key? key,
    required this.categoryPath,
    required this.categoryName,
  }) : super(key: key);

  @override
  _HewanScreenState createState() => _HewanScreenState();
}

class _HewanScreenState extends State<HewanScreen> {
  late DatabaseReference databaseRef;
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Map<String, dynamic>> musicList = [];
  bool isLoading = true;
  int currentIndex = -1;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    databaseRef = FirebaseDatabase.instance.ref(
      'devices/devices_01/music/categories/kategori_001/files',
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
                    'file_id': e.value['file_id'] ?? '',
                  },
                )
                .toList();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void togglePlayPause(int index) async {
    if (currentIndex == index && isPlaying) {
      await _audioPlayer.pause();
      setState(() => isPlaying = false);
    } else {
      await _audioPlayer.stop();
      final fileId = musicList[index]['file_id'];
      final url = 'http://localhost:3000/stream/$fileId';

      await _audioPlayer.play(UrlSource(url));
      setState(() {
        currentIndex = index;
        isPlaying = true;
      });

      _audioPlayer.onPlayerComplete.listen((event) {
        setState(() => isPlaying = false);
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('devices/devices_01/music/categories/kategori_001/files'),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: musicList.length,
                itemBuilder: (context, index) {
                  final music = musicList[index];
                  return ListTile(
                    title: Text(music['title']),
                    trailing: IconButton(
                      icon: Icon(
                        currentIndex == index && isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                      onPressed: () => togglePlayPause(index),
                    ),
                  );
                },
              ),
    );
  }
}
