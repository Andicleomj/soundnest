import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:soundnest/screens/home/murottal/ayat_kursi.dart';
import 'package:soundnest/screens/home/murottal/surah_screen.dart';
import 'package:soundnest/service/music_player_service.dart';

class MurottalScreen extends StatefulWidget {
  const MurottalScreen({super.key});

  @override
  State<MurottalScreen> createState() => _MurottalScreenState();
}

class _MurottalScreenState extends State<MurottalScreen> {
  final DatabaseReference categoriesRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/murottal/categories',
  );

  final List<String> defaultCategories = ['Ayat Kursi', 'Surah Pendek'];
  List<String> customCategories = [];
  List<Map<String, dynamic>> searchResults = [];

  final TextEditingController _searchController = TextEditingController();

  // MusicPlayerService instance (pastikan ini singleton agar state konsisten)
  final MusicPlayerService musicPlayerService = MusicPlayerService();
  // Dua listener terpisah untuk notifiers isPlaying dan currentTitle
  late VoidCallback _isPlayingListener;
  late VoidCallback _currentTitleListener;
  late VoidCallback _currentPositionListener;
  late VoidCallback _durationListener;

  @override
  void initState() {
    super.initState();
    fetchCustomCategories();

    _isPlayingListener = () => setState(() {});
    _currentTitleListener = () => setState(() {});
    _currentPositionListener = () => setState(() {});
    _durationListener = () => setState(() {});

    musicPlayerService.isPlayingNotifier.addListener(_isPlayingListener);
    musicPlayerService.currentTitleNotifier.addListener(_currentTitleListener);
    musicPlayerService.currentPositionNotifier.addListener(_currentPositionListener);
    musicPlayerService.durationNotifier.addListener(_durationListener);
  }

  @override
  void dispose() {
    _searchController.dispose();
    musicPlayerService.isPlayingNotifier.removeListener(_isPlayingListener);
    musicPlayerService.currentTitleNotifier.removeListener(_currentTitleListener);
    musicPlayerService.currentPositionNotifier.removeListener(_currentPositionListener);
    musicPlayerService.durationNotifier.removeListener(_durationListener);
    super.dispose();
  }

  // Ambil kategori kustom dari Firebase Realtime Database
  Future<void> fetchCustomCategories() async {
    final snapshot = await categoriesRef.get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final keys = data.keys.toList();
      final titles = <String>[];

      for (var key in keys) {
        final files = data[key];
        if (files is Map && files.containsKey('name')) {
          final name = files['name'];
          if (name is String) {
            titles.add(name);
          }
        }
      }

      setState(() {
        customCategories =
            titles.where((name) => !defaultCategories.contains(name)).toList();
      });
    }
  }

  Future<void> searchAudio(String query) async {
    final snapshot = await categoriesRef.get();
    final results = <Map<String, dynamic>>[];

    if (snapshot.exists) {
      final categories = Map<String, dynamic>.from(snapshot.value as Map);

      for (var category in categories.entries) {
        final categoryData = Map<String, dynamic>.from(category.value);
        final files = Map<String, dynamic>.from(categoryData['files'] ?? {});

        for (var file in files.values) {
          if (file is Map && file['title'] != null && file['fileId'] != null) {
            final title = file['title'].toString();
            if (title.toLowerCase().contains(query.toLowerCase())) {
              results.add({
                'title': title,
                'fileId': file['fileId'],
                'category': categoryData['name'] ?? '',
              });
            }
          }
        }
      }
    }

    setState(() => searchResults = results);
  }

  Widget _buildSearchResultList() {
    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final item = searchResults[index];
        return ListTile(
          title: Text(item['title'] ?? 'Tanpa Judul'),
          subtitle: Text(item['category'] ?? ''),
          trailing: IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              final fileId = item['fileId'];
              final title = item['title'] ?? 'Tanpa Judul';
              final category = item['category'] ?? '';
              if (fileId != null && fileId.toString().isNotEmpty) {
                musicPlayerService.playFromFileId(
                  fileId,
                  title: title,
                  category: category,
                );
              } else {
                debugPrint("❌ fileId tidak valid");
              }
            },
          ),
        );
      },
    );
  }

  // Navigasi ke layar kategori tertentu
  void navigateToCategoryScreen(BuildContext context, String category) {
    String categoryPath;
    Widget screen;

    if (category == 'Ayat Kursi') {
      categoryPath = 'devices/devices_01/murottal/categories/kategori_1/files';
      screen = AyatKursi(categoryPath: categoryPath, categoryName: category);
    } else if (category == 'Surah Pendek') {
      categoryPath = 'devices/devices_01/murottal/categories/kategori_2/files';
      screen = SurahScreen(
        categoryPath: categoryPath,
        categoryName: category,
        categoryId: '',
      );
    } else {
      // Buat format key Firebase yang konsisten (lowercase & underscore)
      final formattedCategory = category.toLowerCase().replaceAll(' ', '_');
      categoryPath =
          'devices/devices_01/murottal/categories/$formattedCategory/files';
      screen = SurahScreen(
        categoryPath: categoryPath,
        categoryName: category,
        categoryId: '',
      );
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  // Widget mini player di bawah layar, tampil saat ada musik diputar
  Widget _buildMiniPlayer() {
    if (!musicPlayerService.isPlaying) {
      return const SizedBox.shrink();
    }

    final title = musicPlayerService.currentTitle ?? 'Unknown';
    final category = musicPlayerService.currentCategory ?? '';

    return ValueListenableBuilder<Duration>(
      valueListenable: musicPlayerService.currentPositionNotifier,
      builder: (context, currentPosition, child) {
        return ValueListenableBuilder<Duration>(
          valueListenable: musicPlayerService.durationNotifier,
          builder: (context, duration, child) {
            return Container(
              color: Colors.blue.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.music_note, size: 30, color: Colors.blueAccent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (category.isNotEmpty)
                              Text(
                                category,
                                style: const TextStyle(fontSize: 12, color: Colors.black54),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          musicPlayerService.isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_fill,
                          size: 32,
                          color: Colors.blueAccent,
                        ),
                        onPressed: () {
                          if (musicPlayerService.isPlaying) {
                            musicPlayerService.pauseMusic();
                          } else {
                            musicPlayerService.resumeMusic();
                          }
                        },
                      ),
                    ],
                  ),
                  Slider(
                    value: currentPosition.inSeconds.toDouble(),
                    max: duration.inSeconds.toDouble(),
                    min: 0.0,
                    onChanged: (value) {
                      final newPosition = Duration(seconds: value.toInt());
                      musicPlayerService.seekTo(newPosition);
                    },
                    activeColor: Colors.blueAccent,
                    inactiveColor: Colors.blue.shade200,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(currentPosition),
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        Text(
                          _formatDuration(duration),
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  // Build UI kategori dalam bentuk Grid
  Widget _buildCategoryCard(BuildContext context, String category) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => navigateToCategoryScreen(context, category),
        child: Container(
          height: 80, // Tambahkan tinggi lebih besar
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Center( // Changed from Row to Center for text centering
            child: Text(
              category,
              style: const TextStyle(
                fontSize: 12, // Ukuran teks dikurangi
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center, // Added to ensure text is centered
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/alquran.jpg', fit: BoxFit.cover),
        ),
        // Jika sedang mencari, lapisan putih transparan full screen
        if (searchResults.isNotEmpty)
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.95), // ✅ Full transparent white
            ),
          ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text(
              'Kategori Murottal',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 22,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.blueAccent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      if (value.trim().isEmpty) {
                        setState(() => searchResults = []);
                      } else {
                        searchAudio(value.trim());
                      }
                    },
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Cari judul murottal...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.blueAccent,
                      ),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.blueAccent,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => searchResults = []);
                                  },
                                )
                              : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              // ✅ Jika ada hasil pencarian, tampilkan ListView yang dapat discroll
              Expanded(
                child: searchResults.isNotEmpty
                    ? _buildSearchResultList()
                    : Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 13,
                          mainAxisSpacing: 13,
                          childAspectRatio: 3,
                          children: [
                            ...defaultCategories.map(
                              (cat) => _buildCategoryCard(context, cat),
                            ),
                            ...customCategories.map(
                              (cat) => _buildCategoryCard(context, cat),
                            ),
                          ],
                        ),
                      ),
              ),
              _buildMiniPlayer(),
            ],
          ),
        ),
      ],
    );
  }
}