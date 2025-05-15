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
      setState(() {
        isLoading = false;
      });
      print('Data di path ${widget.categoryPath} tidak ditemukan di database.');
    }
  }

  void playMusic(int index) async {
    final fileId = musicList[index]['file_id'];
    final url = 'http://localhost:3000/stream/$fileId';

    await _audioPlayer.stop();

    try {
      await _audioPlayer.play(UrlSource(url));
      setState(() {
        currentIndex = index;
      });

      _audioPlayer.onPlayerComplete.listen((event) {
        if (currentIndex + 1 < musicList.length) {
          playMusic(currentIndex + 1);
        }
      });
    } catch (e) {
      print('❌ Gagal memutar audio: $e');
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
              colors: [Colors.greenAccent, Colors.white],
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
                      onPressed: () => playMusic(index),
                    ),
                  );
                },
              ),
    );
  }
}
