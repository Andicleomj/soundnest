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
  int currentIndex = -1;

  @override
  void initState() {
    super.initState();
    databaseRef = FirebaseDatabase.instance.ref('devices/devices_01/murottal/categories/kategori_2/files');
    fetchSurahData();
  }

  void fetchSurahData() async {
    final snapshot = await databaseRef.get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      setState(() {
        surahList = data.entries.map((e) {
          final value = e.value as Map<dynamic, dynamic>;
          return {
            'title': value['title'] ?? 'Tidak ada judul',
            'fileId': value['fileId'] ?? '',
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

  void playSurah(int index) async {
    final fileId = surahList[index]['fileId'];
    final url = 'http://192.168.110.224:3000/stream/$fileId'; 

    await _audioPlayer.stop();

    try {
      await _audioPlayer.play(UrlSource(url));
      setState(() {
        currentIndex = index;
      });

      _audioPlayer.onPlayerComplete.listen((event) {
        if (currentIndex + 1 < surahList.length) {
          playSurah(currentIndex + 1);
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
                    return ListTile(
                      title: Text(surah['title']),
                      trailing: IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () => playSurah(index),
                      ),
                    );
                  },
                ),
    );
  }
}
