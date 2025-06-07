import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:soundnest/screens/home/murottal/ayat_kursi.dart';
import 'package:soundnest/screens/home/murottal/surah_screen.dart';
import 'package:soundnest/service/music_player_service.dart';
import 'package:soundnest/service/audio_controller.dart';
import 'package:soundnest/service/cast_service.dart';
import 'package:cast/device.dart';

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

  final CastService _castService = CastService();
  final MusicPlayerService _musicPlayerService = MusicPlayerService();
  late AudioControllerService audioControllerService;

  bool isCasting = false;

  late VoidCallback _isPlayingListener;
  late VoidCallback _currentTitleListener;

  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    fetchCustomCategories();

    audioControllerService = AudioControllerService(
      _castService,
      _musicPlayerService,
    );

    _isPlayingListener = () {
      if (!_disposed) setState(() {});
    };
    _currentTitleListener = () {
      if (!_disposed) setState(() {});
    };

    _musicPlayerService.isPlayingNotifier.addListener(_isPlayingListener);
    _musicPlayerService.currentTitleNotifier.addListener(_currentTitleListener);
  }

  @override
  void dispose() {
    _disposed = true;
    _musicPlayerService.isPlayingNotifier.removeListener(_isPlayingListener);
    _musicPlayerService.currentTitleNotifier.removeListener(
      _currentTitleListener,
    );
    super.dispose();
  }

  Future<void> fetchCustomCategories() async {
    try {
      final snapshot = await categoriesRef.get();
      if (snapshot.exists && snapshot.value != null) {
        // Cek apakah snapshot.value bertipe Map
        if (snapshot.value is Map) {
          final dataRaw = snapshot.value as Map<dynamic, dynamic>;
          final Map<String, dynamic> data = {};

          // Safely convert keys and values to String, dynamic
          dataRaw.forEach((key, value) {
            if (key != null && key is String && value != null) {
              data[key] = value;
            }
          });

          final titles = <String>[];
          data.forEach((key, value) {
            if (value is Map && value.containsKey('name')) {
              final name = value['name'];
              if (name is String) titles.add(name);
            }
          });

          if (!_disposed) {
            setState(() {
              customCategories =
                  titles
                      .where((name) => !defaultCategories.contains(name))
                      .toList();
            });
          }
        }
      }
    } catch (e) {
      // Bisa log error jika perlu
      if (!_disposed) {
        setState(() {
          customCategories = [];
        });
      }
    }
  }

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
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Kategori "$name" ditambahkan')),
                      );
                    }
                  }
                },
                child: const Text('Tambah'),
              ),
            ],
          ),
    );
  }

  void navigateToCategoryScreen(BuildContext context, String category) {
    String categoryPath;
    Widget screen;

    if (category == 'Ayat Kursi') {
      categoryPath = 'devices/devices_01/murottal/categories/kategori_1/files';
      screen = AyatKursi(
        categoryPath: categoryPath,
        categoryName: category,
        audioControllerService: audioControllerService,
        isCasting: isCasting,
        onCastToggle: _toggleCasting,
      );
    } else if (category == 'Surah Pendek') {
      categoryPath = 'devices/devices_01/murottal/categories/kategori_2/files';
      screen = SurahScreen(
        categoryPath: categoryPath,
        categoryName: category,
        audioControllerService: audioControllerService,
        isCasting: isCasting,
        onCastToggle: _toggleCasting,
      );
    } else {
      // Pastikan category tidak null dan string valid
      final formattedCategory = category.toLowerCase().replaceAll(' ', '_');
      categoryPath =
          'devices/devices_01/murottal/categories/$formattedCategory/files';
      screen = SurahScreen(
        categoryPath: categoryPath,
        categoryName: category,
        audioControllerService: audioControllerService,
        isCasting: isCasting,
        onCastToggle: _toggleCasting,
      );
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

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

  Future<void> _deleteCategory(String category) async {
    try {
      final snapshot = await categoriesRef.get();
      if (snapshot.exists) {
        if (snapshot.value is Map) {
          final dataRaw = snapshot.value as Map<dynamic, dynamic>;
          String? keyToDelete;

          dataRaw.forEach((key, value) {
            if (value is Map && value['name'] == category) {
              keyToDelete = key is String ? key : key.toString();
            }
          });

          if (keyToDelete != null) {
            await categoriesRef.child(keyToDelete!).remove();
            await fetchCustomCategories();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Kategori "$category" berhasil dihapus'),
                ),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Kategori "$category" tidak ditemukan')),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menghapus kategori: $e')));
      }
    }
  }

  Future<void> _toggleCasting() async {
    if (isCasting) {
      await audioControllerService.stopAudio(); // hapus onCast: true
      if (!_disposed) {
        setState(() {
          isCasting = false;
        });
      }
    } else {
      if (_castService.devices.isNotEmpty) {
        audioControllerService.selectedDevice = _castService.devices.first;
        await _castService.connectToDevice(
          audioControllerService.selectedDevice!,
        );
        if (!_disposed) {
          setState(() {
            isCasting = true;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak ada perangkat cast tersedia')),
          );
        }
      }
    }
  }

  Widget _buildMiniPlayer() {
    if (!_musicPlayerService.isPlaying) return const SizedBox.shrink();

    final title = _musicPlayerService.currentTitle ?? 'Unknown';
    final category = _musicPlayerService.currentCategory ?? '';
    final fileId = _musicPlayerService.currentFileId;

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

          // 👇 Tombol untuk memilih output
          PopupMenuButton<bool>(
            tooltip: 'Output audio',
            icon: Icon(
              audioControllerService.isCasting
                  ? Icons.cast_connected
                  : Icons.speaker,
              color: Colors.blueAccent,
            ),
            onSelected: (bool toCast) async {
              if (fileId != null) {
                await audioControllerService.toggleOutput(
                  toCast: toCast,
                  fileId: fileId,
                  title: title,
                );
              }
            },
            itemBuilder:
                (_) => [
                  PopupMenuItem<bool>(
                    value: false,
                    child: Row(
                      children: const [
                        Icon(Icons.speaker, color: Colors.black54),
                        SizedBox(width: 8),
                        Text('Putar di HP'),
                      ],
                    ),
                  ),
                  PopupMenuItem<bool>(
                    value: true,
                    child: Row(
                      children: const [
                        Icon(Icons.cast, color: Colors.black54),
                        SizedBox(width: 8),
                        Text('Putar di Speaker (Cast)'),
                      ],
                    ),
                  ),
                ],
          ),

          const SizedBox(width: 4),

          // 👇 Tombol play/pause
          IconButton(
            icon: Icon(
              _musicPlayerService.isPlaying
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_fill,
              size: 32,
              color: Colors.blueAccent,
            ),
            onPressed: () {
              if (_musicPlayerService.isPlaying) {
                audioControllerService.pauseAudio();
              } else {
                _musicPlayerService.resumeMusic();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(BuildContext context, List<String> categories) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
      child: Row(
        children:
            categories.map((category) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap:
                              () => navigateToCategoryScreen(context, category),
                          child: Text(
                            category,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          size: 20,
                          color: Colors.red,
                        ),
                        onPressed:
                            () => _confirmDeleteCategory(context, category),
                        tooltip: 'Hapus $category',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allCategories = [...defaultCategories, ...customCategories];
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/alquran.jpg', fit: BoxFit.cover),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text(
              'Kategori Murottal',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.blue.shade400,
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Tambah Kategori',
                onPressed: _showAddCategoryDialog,
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  itemCount: (allCategories.length / 2).ceil(),
                  itemBuilder: (context, index) {
                    final startIndex = index * 2;
                    final endIndex =
                        (startIndex + 2 <= allCategories.length)
                            ? startIndex + 2
                            : allCategories.length;
                    final rowItems = allCategories.sublist(
                      startIndex,
                      endIndex,
                    );
                    return _buildCategoryRow(context, rowItems);
                  },
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
