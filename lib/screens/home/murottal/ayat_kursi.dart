import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:audioplayers/audioplayers.dart';

class AyatKursi extends StatefulWidget {
  final String categoryPath;
  final String categoryName;

  const AyatKursi({
    Key? key,
    required this.categoryPath,
    required this.categoryName,
  }) : super(key: key);

  @override
  _AyatKursiState createState() => _AyatKursiState();
}

class _AyatKursiState extends State<AyatKursi> {
  late DatabaseReference databaseRef;
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Map<String, dynamic>> surahList = [];
  bool isLoading = true;
  int? currentIndex;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    databaseRef = FirebaseDatabase.instance.ref(widget.categoryPath);
    fetchSurahData();
  }

  void fetchSurahData() async {
    final snapshot = await databaseRef.get();
    if (snapshot.exists) {
      try {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final List<Map<String, dynamic>> tempList = [];

        data.forEach((key, value) {
          if (value is Map &&
              value.containsKey('title') &&
              value.containsKey('fileId')) {
            tempList.add({'title': value['title'], 'fileId': value['fileId']});
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
      print('⚠️ Data tidak ditemukan di path: ${widget.categoryPath}');
      setState(() => isLoading = false);
    }
  }

  /// Fungsi untuk mendapatkan daftar surah secara eksternal (untuk JadwalMurottal)
  List<String> getSurahList() {
    return surahList.map((surah) => surah['title'] as String).toList();
  }

  void togglePlay(int index) async {
    final fileId = surahList[index]['fileId'];
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
              : surahList.isEmpty
              ? const Center(child: Text('Data surah tidak tersedia.'))
              : ListView.builder(
                itemCount: surahList.length,
                itemBuilder: (context, index) {
                  final surah = surahList[index];
                  final isCurrent = currentIndex == index && isPlaying;

                  return ListTile(
                    title: Text(surah['title']),
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
