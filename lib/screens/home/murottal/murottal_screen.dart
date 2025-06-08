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

  // MusicPlayerService instance (pastikan ini singleton agar state konsisten)
  final MusicPlayerService musicPlayerService = MusicPlayerService();

  // Dua listener terpisah untuk notifiers isPlaying dan currentTitle
  late VoidCallback _isPlayingListener;
  late VoidCallback _currentTitleListener;

  @override
  void initState() {
    super.initState();
    fetchCustomCategories();

    _isPlayingListener = () => setState(() {});
    _currentTitleListener = () => setState(() {});

    musicPlayerService.isPlayingNotifier.addListener(_isPlayingListener);
    musicPlayerService.currentTitleNotifier.addListener(_currentTitleListener);
  }

  @override
  void dispose() {
    musicPlayerService.isPlayingNotifier.removeListener(_isPlayingListener);
    musicPlayerService.currentTitleNotifier.removeListener(
      _currentTitleListener,
    );
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

  // Dialog tambah kategori baru
  void _showAddCategoryDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Tambah Kategori Baru'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'Nama kategori'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = controller.text.trim();
                  if (name.isNotEmpty) {
                    final newRef = categoriesRef.push();
                    await newRef.set({'name': name, 'files': {}});
                    Navigator.pop(context);
                    await fetchCustomCategories();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Kategori "$name" ditambahkan')),
                    );
                  }
                },
                child: const Text('Tambah'),
              ),
            ],
          ),
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

  // Konfirmasi hapus kategori kustom
  void _confirmDeleteCategory(BuildContext context, String category) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Hapus Kategori'),
            content: Text(
              'Apakah Anda yakin ingin menghapus kategori "$category"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _deleteCategory(category);
                },
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
  }

  // Hapus kategori dari Firebase Realtime Database
  Future<void> _deleteCategory(String category) async {
    try {
      final snapshot = await categoriesRef.get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        String? keyToDelete;

        data.forEach((key, value) {
          if (value is Map && value['name'] == category) {
            keyToDelete = key;
          }
        });

        if (keyToDelete != null) {
          await categoriesRef.child(keyToDelete!).remove();
          await fetchCustomCategories();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Kategori "$category" berhasil dihapus')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Kategori "$category" tidak ditemukan')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus kategori: $e')));
    }
  }

  // Widget mini player di bawah layar, tampil saat ada musik diputar
  Widget _buildMiniPlayer() {
    if (!musicPlayerService.isPlaying) {
      return const SizedBox.shrink();
    }

    final title = musicPlayerService.currentTitle ?? 'Unknown';
    final category = musicPlayerService.currentCategory ?? '';

    return Container(
      color: Colors.blue.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Row(
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
    );
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
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 12, // Ukuran teks dikurangi
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDeleteCategory(context, category),
                ),
              ),
            ],
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
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text(
              'Kategori Musrottal',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.add, color: Colors.black),
                tooltip: 'Tambah Kategori',
                onPressed: _showAddCategoryDialog,
              ),
            ],
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
          body: Column(
            children: [
              Expanded(
                child: Padding(
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