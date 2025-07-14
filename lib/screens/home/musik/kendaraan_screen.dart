import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:soundnest/service/music_player_service.dart';

final MusicPlayerService musicPlayerService = MusicPlayerService();

class KendaraanScreen extends StatefulWidget {
  final String categoryPath; // Path lengkap di Firebase Realtime Database
  final String categoryName; // Nama kategori untuk judul AppBar
  final bool selectMode;

  const KendaraanScreen({
    super.key,
    required this.categoryPath,
    required this.categoryName,
    this.selectMode = false,
  });

  @override
  _KendaraanScreenState createState() => _KendaraanScreenState();
}

class _KendaraanScreenState extends State<KendaraanScreen> {
  late DatabaseReference databaseRef;
  List<Map<String, dynamic>> motorList = [];
  bool isLoading = true;
  int currentIndex = -1;

  @override
  void initState() {
    super.initState();
    databaseRef = FirebaseDatabase.instance.ref(
      'devices/devices_01/music/categories/kategori_002/files',
    );
    fetchMusicData();
  }

  void fetchMusicData() async {
    final snapshot = await databaseRef.get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      setState(() {
        motorList =
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
    final fileId = motorList[index]['fileId'];

    if (musicPlayerService.isPlaying &&
        musicPlayerService.currentFileId == fileId) {
      await musicPlayerService.pauseMusic();
      setState(() {
        currentIndex = -1;
      });
    } else {
      await musicPlayerService.playFromFileId(
        fileId,
        title: motorList[index]['title'],
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
                  "Kendaraan",
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
                        : motorList.isEmpty
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
                          itemCount: motorList.length,
                          separatorBuilder:
                              (context, index) => const Divider(
                                color: Colors.white30,
                                thickness: 0.5,
                                height: 0.5,
                              ),
                          itemBuilder: (context, index) {
                            final music = motorList[index];
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
