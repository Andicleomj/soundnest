import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:soundnest/screens/home/musik/Olahraga_screen.dart';
import 'package:soundnest/screens/home/musik/hewan_screen.dart';
import 'package:soundnest/screens/home/musik/kendaraan_screen.dart';
import 'package:soundnest/screens/home/musik/profesi_screen.dart';
import 'package:soundnest/screens/home/musik/adaptasi_screen.dart';
import 'package:soundnest/screens/home/musik/family_screen.dart';
import 'package:soundnest/screens/home/musik/bumi_screen.dart';
import 'package:soundnest/screens/home/musik/hari_screen.dart';
import 'package:soundnest/screens/home/musik/ramadhan_screen.dart';
import 'package:soundnest/screens/home/musik/haji_screen.dart';
import 'package:soundnest/screens/home/musik/mama_screen.dart';
import 'package:soundnest/screens/home/musik/sunda_screen.dart';
import 'package:soundnest/screens/home/musik/guru_screen.dart';
import 'package:soundnest/service/music_player_service.dart';

final musicPlayerService = MusicPlayerService();

class MusicScreen extends StatelessWidget {
  final bool selectMode;

  const MusicScreen({super.key, this.selectMode = false});

  @override
  Widget build(BuildContext context) {
    return _MusicScreenStateful(selectMode: selectMode);
  }
}

class _MusicScreenStateful extends StatefulWidget {
  final bool selectMode;

  const _MusicScreenStateful({this.selectMode = false});

  @override
  State<_MusicScreenStateful> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<_MusicScreenStateful> {
  List<Map<String, dynamic>> dynamicCategories = [];
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];

  @override
  void initState() {
    super.initState();
    fetchDynamicCategories();
  }

  void fetchDynamicCategories() {
    final dbRef = FirebaseDatabase.instance.ref(
      'devices/devices_01/music/categories',
    );
    dbRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        final List<Map<String, dynamic>> loadedCategories = [];
        data.forEach((key, value) {
          if (value is Map && value['name'] != null) {
            loadedCategories.add({'key': key, 'name': value['name']});
          }
        });
        setState(() {
          dynamicCategories = loadedCategories;
        });
      } else {
        setState(() {
          dynamicCategories = [];
        });
      }
    });
  }

  void deleteCategory(String key) async {
    final dbRef = FirebaseDatabase.instance.ref(
      'devices/devices_01/music/categories/$key',
    );
    await dbRef.remove();
  }

  void searchAudio(String query) async {
    final dbRef = FirebaseDatabase.instance.ref(
      'devices/devices_01/music/categories',
    );
    final snapshot = await dbRef.get();
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

  Widget _buildSearchResults() {
    return ListView.builder(
      shrinkWrap: true, // Memungkinkan ListView mengambil ruang yang dibutuhkan
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final item = searchResults[index];
        return ListTile(
          leading: const Icon(Icons.music_note),
          title: Text(item['title'] ?? 'Tanpa Judul'),
          subtitle: Text(item['category'] ?? ''),
          trailing: IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              final title = item['title'] ?? 'Tanpa Judul';
              final category = item['category'] ?? '';
              final fileId = item['fileId'] ?? '';
              musicPlayerService.playFromFileId(
                fileId,
                title: title,
                category: category,
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MusicScreenWithDynamicCategories(
      dynamicCategories: dynamicCategories,
      onDelete: deleteCategory,
      searchController: _searchController,
      onSearchChanged: (value) {
        if (value.trim().isNotEmpty) {
          searchAudio(value.trim());
        } else {
          setState(() => searchResults.clear());
        }
      },
      searchResults: searchResults,
      buildSearchResults: _buildSearchResults,
    );
  }
}

class MusicScreenWithDynamicCategories extends StatelessWidget {
  final List<Map<String, dynamic>> dynamicCategories;
  final Function(String key) onDelete;
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final List<Map<String, dynamic>> searchResults;
  final Widget Function() buildSearchResults;

  const MusicScreenWithDynamicCategories({
    super.key,
    required this.dynamicCategories,
    required this.onDelete,
    required this.searchController,
    required this.onSearchChanged,
    required this.searchResults,
    required this.buildSearchResults,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/musik.jpg', fit: BoxFit.cover),
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
              'Kategori Musik',
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
            actions: [
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  showAddCategoryDialog(context);
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Cari judul musik...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.blueAccent,
                    ),
                    suffixIcon:
                        searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.blueAccent,
                                ),
                                onPressed: () {
                                  searchController.clear();
                                  onSearchChanged('');
                                },
                              )
                            : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    filled: true,
                    fillColor: Colors.blue.shade100,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ),
              if (searchResults.isNotEmpty)
                Expanded(child: buildSearchResults())
              else
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildCategoryGrid(context, [
                            'Masa Adaptasi Sekolah',
                            'Aku Suka Olahraga',
                            'My Family',
                            'Bumi Planet',
                            'Hari Kemerdekaan',
                            'Ramadhan',
                            'Hewan',
                            'Manasik Haji',
                            'Budaya Sunda',
                            'Batik',
                            'Mother Day',
                            'Guruku Tersayang',
                            'Profesi',
                            'Kendaraan',
                          ], isDeletable: true),
                          const SizedBox(height: 20),
                          if (dynamicCategories.isNotEmpty)
                            _buildDynamicCategoryGrid(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ValueListenableBuilder<bool>(
                valueListenable: musicPlayerService.isPlayingNotifier,
                builder: (context, isPlaying, _) {
                  if (!isPlaying || musicPlayerService.currentTitle == null) {
                    return const SizedBox.shrink();
                  }
                  return ValueListenableBuilder<Duration>(
                    valueListenable: musicPlayerService.currentPositionNotifier,
                    builder: (context, currentPosition, child) {
                      return ValueListenableBuilder<Duration>(
                        valueListenable: musicPlayerService.durationNotifier,
                        builder: (context, duration, child) {
                          return Container(
                            color: Colors.blue.shade100,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 8,
                            ), // Sama dengan MurottalScreen
                            child: Column(
                              mainAxisSize: MainAxisSize.min, // Kontrol ukuran berdasarkan konten
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.music_note,
                                      size: 30,
                                      color: Colors.blueAccent,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ValueListenableBuilder<String?>(
                                            valueListenable:
                                                musicPlayerService.currentTitleNotifier,
                                            builder: (context, title, _) => Text(
                                              title ?? '',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          ValueListenableBuilder<String?>(
                                            valueListenable:
                                                musicPlayerService.currentCategoryNotifier,
                                            builder: (context, category, _) => Text(
                                              category ?? '',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black54,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
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
                                  value: currentPosition.inSeconds.toDouble().clamp(
                                        0.0,
                                        duration.inSeconds.toDouble(),
                                      ),
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
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      Text(
                                        _formatDuration(duration),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
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
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Widget _buildCategoryGrid(
    BuildContext context,
    List<String> categories, {
    bool isDeletable = false,
  }) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 13,
      mainAxisSpacing: 13,
      childAspectRatio: 2.2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: categories.map((category) {
        // Untuk kategori statis, keyOrName kita isi dengan nama kategori agar tombol hapus muncul
        return _buildCategoryCard(
          context,
          category,
          isDeletable ? category : null,
        );
      }).toList(),
    );
  }

  Widget _buildDynamicCategoryGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 13,
      mainAxisSpacing: 13,
      childAspectRatio: 2.2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: dynamicCategories.map((cat) {
        return _buildCategoryCard(context, cat['name'], cat['key']);
      }).toList(),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String category,
    String? keyOrName,
  ) {
    return Card(
      color: Colors.blue.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          navigateToCategoryScreen(context, category, this, true);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Tulisan kategori rata kiri dan ambil space sebanyak mungkin
              Expanded(
                child: Text(
                  category,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),

              // Jika ada keyOrName (kategori yang bisa dihapus), tampilkan icon delete
              if (keyOrName != null)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () async {
                    if (keyOrName.startsWith('kategori_') ||
                        keyOrName.length <= 20) {
                      onDelete(keyOrName);
                    } else {
                      final dbRef = FirebaseDatabase.instance.ref(
                        'devices/devices_01/music/categories',
                      );
                      final snapshot =
                          await dbRef
                              .orderByChild('name')
                              .equalTo(keyOrName)
                              .get();
                      if (snapshot.exists) {
                        final data = snapshot.value as Map;
                        final deleteKey = data.keys.first;
                        onDelete(deleteKey);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Kategori "$keyOrName" tidak ditemukan di database',
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void navigateToCategoryScreen(
    BuildContext context,
    String category,
    dynamic widget,
    bool selectMode,
  ) {
    String categoryPath;
    Widget screen;

    switch (category) {
      case 'Hewan':
        categoryPath = 'devices/devices_01/music/categories/kategori_001/files';
        screen = HewanScreen(
          categoryPath: categoryPath,
          categoryName: category,
          selectMode: selectMode,
        );
        break;
      case 'Kendaraan':
        categoryPath = 'devices/devices_01/music/categories/kategori_002/files';
        screen = KendaraanScreen(
          categoryPath: categoryPath,
          categoryName: category,
          selectMode: selectMode,
        );
        break;
      case 'Aku Suka Olahraga':
        categoryPath = 'devices/devices_01/music/categories/kategori_003/files';
        screen = OlahragaScreen(
          categoryPath: categoryPath,
          categoryName: category,
          selectMode: selectMode,
        );
        break;
      case 'Profesi':
        categoryPath = 'devices/devices_01/music/categories/kategori_013/files';
        screen = ProfesiScreen(
          categoryPath: categoryPath,
          categoryName: category,
          selectMode: selectMode,
        );
        break;
      case 'Masa Adaptasi Sekolah':
        categoryPath = 'devices/devices_01/music/categories/kategori_004/files';
        screen = AdaptasiScreen(
          categoryPath: categoryPath,
          categoryName: category,
          selectMode: selectMode,
        );
        break;
      case 'My Family':
        categoryPath = 'devices/devices_01/music/categories/kategori_005/files';
        screen = FamilyScreen(
          categoryPath: categoryPath,
          categoryName: category,
          selectMode: selectMode,
        );
        break;
      case 'Bumi Planet':
        categoryPath = 'devices/devices_01/music/categories/kategori_006/files';
        screen = BumiScreen(
          categoryPath: categoryPath,
          categoryName: category,
          selectMode: selectMode,
        );
        break;
      case 'Hari Kemerdekaan':
        categoryPath = 'devices/devices_01/music/categories/kategori_007/files';
        screen = HariScreen(
          categoryPath: categoryPath,
          categoryName: category,
          selectMode: selectMode,
        );
        break;
      case 'Ramadhan':
        categoryPath = 'devices/devices_01/music/categories/kategori_008/files';
        screen = RamadhanScreen(
          categoryPath: categoryPath,
          categoryName: category,
          selectMode: selectMode,
        );
        break;
      case 'Manasik Haji':
        categoryPath = 'devices/devices_01/music/categories/kategori_009/files';
        screen = HajiScreen(
          categoryPath: categoryPath,
          categoryName: category,
          selectMode: selectMode,
        );
        break;
      case 'Budaya Sunda':
        categoryPath = 'devices/devices_01/music/categories/kategori_010/files';
        screen = SundaScreen(
          categoryPath: categoryPath,
          categoryName: category,
          selectMode: selectMode,
        );
        break;
      case 'Batik':
        categoryPath = 'devices/devices_01/music/categories/kategori_011/files';
        screen = SundaScreen(
          categoryPath: categoryPath,
          categoryName: category,
          selectMode: selectMode,
        );
        break;
      case 'Mother Day':
        categoryPath = 'devices/devices_01/music/categories/kategori_012/files';
        screen = MamaScreen(
          categoryPath: categoryPath,
          categoryName: category,
          selectMode: selectMode,
        );
        break;
      case 'Guruku Tersayang':
        categoryPath = 'devices/devices_01/music/categories/kategori_014/files';
        screen = GuruScreen(
          categoryPath: categoryPath,
          categoryName: category,
          selectMode: selectMode,
        );
        break;
      default:
        categoryPath = '';
        screen = Scaffold(
          appBar: AppBar(title: Text(category)),
          body: Center(child: Text('Kategori "$category" belum tersedia')),
        );
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => screen)).then((
      selectedMusic,
    ) {
      if (selectedMusic != null && widget.selectMode) {
        Navigator.pop(context, selectedMusic);
      }
    });
  }

  void addCategoryToFirebase(String name) {
    final dbRef = FirebaseDatabase.instance.ref(
      'devices/devices_01/music/categories',
    );
    final newKey = dbRef.push().key;
    if (newKey != null) {
      dbRef.child(newKey).set({'name': name});
    }
  }

  void showAddCategoryDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tambah Kategori Baru'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: 'Masukkan nama kategori',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  addCategoryToFirebase(name);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }
}