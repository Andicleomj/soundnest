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
import 'package:soundnest/screens/schedule/musik.dart';

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

  @override
  Widget build(BuildContext context) {
    return MusicScreenWithDynamicCategories(
      dynamicCategories: dynamicCategories,
      onDelete: deleteCategory,
    );
  }
}

class MusicScreenWithDynamicCategories extends StatelessWidget {
  final List<Map<String, dynamic>> dynamicCategories;
  final Function(String key) onDelete;

  const MusicScreenWithDynamicCategories({
    super.key,
    required this.dynamicCategories,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/musik.jpg', fit: BoxFit.cover),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text(
              'Kategori Musik',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
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
            actions: [
              IconButton(
                icon: const Icon(Icons.add, color: Colors.black),
                onPressed: () {
                  showAddCategoryDialog(context);
                },
              ),
            ],
          ),
          body: Padding(
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

                  if (dynamicCategories.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildDynamicCategoryGrid(context),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
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
      childAspectRatio: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children:
          categories.map((category) {
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
      childAspectRatio: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children:
          dynamicCategories.map((cat) {
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
                    fontSize: 15,
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

    // baru di tambah !!

    switch (category) {
      case 'Hewan':
        categoryPath = 'devices/devices_01/music/categories/kategori_001/files';
        screen = HewanScreen(
          categoryPath: categoryPath,
          categoryName: category,
          selectMode: true,
        );
        break;
      case 'Kendaraan':
        categoryPath = 'devices/devices_01/music/categories/kategori_002/files';
        screen = KendaraanScreen(
          categoryPath: categoryPath,
          categoryName: category,
          selectMode: true,
        );
        break;
      case 'Aku Suka Olahraga':
        categoryPath = 'devices/devices_01/music/categories/kategori_003/files';
        screen = OlahragaScreen(
          categoryPath: categoryPath,
          categoryName: category,
          selectMode: true,
        );
        break;
      case 'Profesi':
        categoryPath = 'devices/devices_01/music/categories/kategori_013/files';
        screen = ProfesiScreen(
          categoryPath: categoryPath,
          categoryName: category,
          selectMode: true,
        );
        break;
      case 'Masa Adaptasi Sekolah':
        categoryPath = 'devices/devices_01/music/categories/kategori_004/files';
        screen = AdaptasiScreen(
          categoryPath: categoryPath,
          categoryName: category,
          selectMode: true,
        );
        break;
      case 'My Family':
        categoryPath = 'devices/devices_01/music/categories/kategori_005/files';
        screen = FamilyScreen(
          categoryPath: categoryPath,
          categoryName: category,
          selectMode: true,
        );
        break;
      case 'Bumi Planet':
        categoryPath = 'devices/devices_01/music/categories/kategori_006/files';
        screen = BumiScreen(
          categoryPath: categoryPath,
          categoryName: category,
          selectMode: true,
        );
        break;
      case 'Hari Kemerdekaan':
        categoryPath = 'devices/devices_01/music/categories/kategori_007/files';
        screen = HariScreen(
          categoryPath: categoryPath,
          categoryName: category,
          selectMode: true,
        );
        break;
      case 'Ramadhan':
        categoryPath = 'devices/devices_01/music/categories/kategori_008/files';
        screen = RamadhanScreen(
          categoryPath: categoryPath,
          categoryName: category,
          selectMode: true,
        );
        break;
      case 'Manasik Haji':
        categoryPath = 'devices/devices_01/music/categories/kategori_009/files';
        screen = HajiScreen(
          categoryPath: categoryPath,
          categoryName: category,
          selectMode: true,
        );
        break;
      case 'Budaya Sunda':
        categoryPath = 'devices/devices_01/music/categories/kategori_010/files';
        screen = SundaScreen(
          categoryPath: categoryPath,
          categoryName: category,
          selectMode: true,
        );
        break;
      case 'Batik':
        categoryPath = 'devices/devices_01/music/categories/kategori_011/files';
        screen = SundaScreen(
          categoryPath: categoryPath,
          categoryName: category,
          selectMode: true,
        );
        break;
      case 'Mother Day':
        categoryPath = 'devices/devices_01/music/categories/kategori_012/files';
        screen = MamaScreen(
          categoryPath: categoryPath,
          categoryName: category,
          selectMode: true,
        );
        break;
      case 'Guruku Tersayang':
        categoryPath = 'devices/devices_01/music/categories/kategori_014/files';
        screen = GuruScreen(
          categoryPath: categoryPath,
          categoryName: category,
          selectMode: true,
        );
        break;
      default:
        // Default jika kategori tidak dikenal
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
        // Setelah pilih musik di layar kategori, langsung lanjut ke form jadwal
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => MusikScheduleForm(
                  title: selectedMusic['title'],
                  fileId: selectedMusic['file_id'],
                  category: selectedMusic['category'],
                ),
          ),
        );
      }
    });
  }
  // Fungsi untuk menambahkan kategori baru ke Firebase Realtime Database

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

//baru
