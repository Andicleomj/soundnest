import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:audioplayers/audioplayers.dart';

class AdaptasiScreen extends StatefulWidget {
  final String categoryPath; // Path lengkap di Firebase Realtime Database
  final String categoryName; // Nama kategori untuk judul AppBar
  final bool selectMode;
  final bool fromScheduleTab;

  const AdaptasiScreen({
    super.key,
    required this.categoryPath,
    required this.categoryName,
    this.selectMode = false,
    this.fromScheduleTab = false, // default false
  });

  @override
  _AdaptasiScreenState createState() => _AdaptasiScreenState();
}

class _AdaptasiScreenState extends State<AdaptasiScreen> {
  late DatabaseReference databaseRef;
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Map<String, dynamic>> adaptasiList = [];
  bool isLoading = true;
  int currentIndex = -1;
  bool isPlaying = false;

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
                'fileid': value['fileid'] ?? '',
              };
            }).toList();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      print('Data di path ${widget.categoryPath} tidak ditemukan di database.');
    }
  }

  // sudah
  void togglePlay(int index) async {
    final fileId = adaptasiList[index]['fileid'];
    final url = 'http://localhost:3000/stream/$fileId';

    if (isPlaying && currentIndex == index) {
      await _audioPlayer.pause();
      setState(() => isPlaying = false);
    } else {
      await _audioPlayer.stop();
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
                  final isCurrent = currentIndex == index && isPlaying;

                  return ListTile(
                    title: Text(music['title']),
                    onTap: () {
                      if (widget.fromScheduleTab) {
                        // Jika dari tab penjadwalan, kembali dengan data ke form jadwal
                        Navigator.pop(context, {
                          'title': music['title'],
                          'fileid': music['fileid'],
                          'category': widget.categoryName,
                        });
                      } else {
                        // Jika bukan, langsung play musik
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
