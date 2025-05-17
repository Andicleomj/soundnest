import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:audioplayers/audioplayers.dart';

class SurahScreen extends StatefulWidget {
  final String categoryPath;
  final String categoryName;

  const SurahScreen({
    Key? key,
    required this.categoryPath,
    required this.categoryName, required String categoryId,
  }) : super(key: key);

  @override
  _SurahScreenState createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen> {
  late DatabaseReference databaseRef;
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Map<String, dynamic>> surahList = [];
  bool isLoading = true;
  int currentIndex = -1;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    databaseRef = FirebaseDatabase.instance.ref(widget.categoryPath);
    fetchSurahData();

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        currentIndex = -1;
      });
    });
  }

  Future<void> fetchSurahData() async {
    final snapshot = await databaseRef.get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      setState(() {
        surahList = data.entries.map((entry) {
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

  Future<void> togglePlayPause(int index) async {
    final fileId = surahList[index]['fileId'];
    if (fileId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('FileId tidak tersedia')),
      );
      return;
    }

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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : surahList.isEmpty
              ? const Center(child: Text('Data surah tidak tersedia.'))
              : ListView.builder(
                  itemCount: surahList.length,
                  itemBuilder: (context, index) {
                    final surah = surahList[index];
                    final isCurrentPlaying =
                        (currentIndex == index && isPlaying);

                    return ListTile(
                      title: Text(surah['title']),
                      trailing: IconButton(
                        icon: Icon(
                          isCurrentPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                        onPressed: () => togglePlayPause(index),
                      ),
                      onTap: () => togglePlayPause(index),
                    );
                  },
                ),
    );
  }
}
