import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:soundnest/service/music_player_service.dart';

final MusicPlayerService musicPlayerService = MusicPlayerService();

class AyatKursi extends StatefulWidget {
  final String categoryPath;
  final String categoryName;

  const AyatKursi({
    super.key,
    required this.categoryPath,
    required this.categoryName,
  });

  @override
  _AyatKursiState createState() => _AyatKursiState();
}

class _AyatKursiState extends State<AyatKursi> {
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  "Ayat Kursi",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
                centerTitle: true,
              ),
              Expanded(
                child:
                    isLoading
                        ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                        : surahList.isEmpty
                        ? const Center(
                          child: Text(
                            'Data musik tidak tersedia.',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                        : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 4,
                          ),
                          itemCount: surahList.length,
                          separatorBuilder:
                              (context, index) => const Divider(
                                color: Colors.white30,
                                thickness: 0.5,
                                height: 0.5,
                              ),
                          itemBuilder: (context, index) {
                            final music = surahList[index];
                            final isCurrent =
                                musicPlayerService.currentFileId ==
                                    music['fileId'] &&
                                musicPlayerService.isPlaying;

                            return Card(
                              elevation: 1,
                              margin: const EdgeInsets.symmetric(
                                vertical: 2,
                                horizontal: 4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              color:
                                  isCurrent
                                      ? Colors.lightBlue[50]!.withOpacity(0.5)
                                      : Colors.white.withOpacity(0.9),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(8),
                                leading: const Icon(
                                  Icons.music_note,
                                  color: Colors.blueAccent,
                                  size: 24,
                                ),
                                title: Text(
                                  music['title'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        isCurrent
                                            ? Colors.blueAccent
                                            : Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    isCurrent ? Icons.pause : Icons.play_arrow,
                                    color:
                                        isCurrent
                                            ? Colors.blueAccent
                                            : Colors.black54,
                                    size: 24,
                                  ),
                                  onPressed: () => togglePlay(index),
                                ),
                                onTap: () => togglePlay(index),
                                splashColor: Colors.blueAccent.withOpacity(0.3),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
