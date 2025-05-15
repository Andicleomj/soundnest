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
      try {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final List<Map<String, dynamic>> tempList = [];

        data.forEach((key, value) {
          if (value is Map &&
              value.containsKey('title') &&
              value.containsKey('file_id')) {
            tempList.add({
              'title': value['title'],
              'file_id': value['file_id'],
            });
          }
        });

        setState(() {
          musicList = tempList;
          isLoading = false;
        });
      } catch (e) {
        print('❌ Gagal parsing data: $e');
        setState(() => isLoading = false);
      }
    } else {
      print(
        '⚠️ Data tidak ditemukan di path: ${'devices/devices_01/music/categories/kategori_001/files'}',
      );
      setState(() => isLoading = false);
    }
  }

  void togglePlayPause(int index) async {
    final fileId = musicList[index]['file_id'];
    final url = 'http://localhost:3000/stream/$fileId';

    // Jika sedang memainkan surah yang sama → PAUSE
    if (isPlaying && currentIndex == index) {
      await _audioPlayer.pause();
      setState(() => isPlaying = false);
    }
    // Jika sedang tidak memainkan atau berpindah surah → PLAY
    else {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
      setState(() {
        currentIndex = index;
        isPlaying = true;
      });

      _audioPlayer.onPlayerComplete.listen((event) {
        setState(() {
          isPlaying = false;
        });
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.categoryName),
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
                  return ListTile(
                    title: Text(music['title']),
                    trailing: IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () => togglePlayPause(index),
                    ),
                  );
                },
              ),
    );
  }
}
