import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:soundnest/screens/home/murottal/ayat_kursi.dart';
import 'package:soundnest/screens/home/murottal/surah_screen.dart';

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

  @override
  void initState() {
    super.initState();
    fetchCustomCategories();
  }

  Future<void> fetchCustomCategories() async {
    final snapshot = await categoriesRef.get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final keys = data.keys.toList();
      final titles = <String>[];

      for (var key in keys) {
        final files = data[key];
        if (files is Map && files['name'] != null) {
          titles.add(files['name']);
        }
      }

      setState(() {
        customCategories =
            titles.where((name) => !defaultCategories.contains(name)).toList();
      });
    }
  }

  void _showAddCategoryDialog() {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
                title: const Text('Tambah Kategori Baru'),
                content: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(hintText: 'Nama kategori'),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final name = _controller.text.trim();
                      if (name.isNotEmpty) {
                        final newRef = categoriesRef.push();
                        await newRef.set({'name': name, 'files': {}});
                        Navigator.pop(context);
                        fetchCustomCategories();
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
      screen = SurahScreen(
        categoryPath:
            'devices/devices_01/murottal/categories/${category.toLowerCase().replaceAll(' ', '_')}/files',
        categoryName: category,
        categoryId: '',
      );
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  void _confirmDeleteCategory(BuildContext context, String category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Kategori'),
        content: Text('Apakah Anda yakin ingin menghapus kategori "$category"?'),
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
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        String? keyToDelete;

        data.forEach((key, value) {
          if (value is Map && value['name'] == category) {
            keyToDelete = key;
          }
        });

        if (keyToDelete != null) {
          await categoriesRef.child(keyToDelete!).remove();
          fetchCustomCategories();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus kategori: $e')),
      );
    }
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
              'Kategori Musik',
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
          body: Padding(
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
      ],
    );
  }

  Widget _buildCategoryCard(BuildContext context, String category) {
    return GestureDetector(
      onTap: () => navigateToCategoryScreen(context, category),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        color: Colors.blue.shade100,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  category,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDeleteCategory(context, category),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
