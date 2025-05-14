// lib/screens/home/musik/music_category_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:soundnest/service/music_file_management.dart';
import 'package:soundnest/screens/home/musik/daftar_musik.dart';

class MusicCategoryScreen extends StatefulWidget {
  const MusicCategoryScreen({super.key});

  @override
  State<MusicCategoryScreen> createState() => _MusicCategoryScreenState();
}

class _MusicCategoryScreenState extends State<MusicCategoryScreen> {
  final DatabaseReference _musicRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/music/categories',
  );
  Map<String, dynamic> _categories = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final snapshot = await _musicRef.get();
    if (snapshot.exists) {
      setState(() {
        _categories = Map<String, dynamic>.from(snapshot.value as Map);
        _isLoading = false;
      });
    }
  }

  void _navigateToCategory(String categoryId, String categoryName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => DaftarMusikScreen(
              categoryId: categoryId,
              categoryName: categoryName,
            ),
      ),
    );
  }

  void _showAddMusicDialog() async {
    String? selectedCategory;
    String title = '';
    String fileId = '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Tambah Musik"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items:
                    _categories.keys.map((key) {
                      return DropdownMenuItem(
                        value: key,
                        child: Text(_categories[key]['name'] ?? 'Unknown'),
                      );
                    }).toList(),
                onChanged: (value) {
                  selectedCategory = value;
                },
                decoration: const InputDecoration(labelText: "Kategori"),
              ),
              TextField(
                onChanged: (value) => title = value,
                decoration: const InputDecoration(labelText: "Judul Musik"),
              ),
              TextField(
                onChanged: (value) => fileId = value,
                decoration: const InputDecoration(labelText: "File ID"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (selectedCategory != null &&
                    title.isNotEmpty &&
                    fileId.isNotEmpty) {
                  _addNewFile(selectedCategory!, title, fileId);
                }
              },
              child: const Text("Tambah"),
            ),
          ],
        );
      },
    );
  }

  void _addNewFile(String categoryId, String title, String fileId) async {
    final success = await MusicFileManagement.addFileToCategory(
      categoryId,
      fileId,
      title,
    );

    if (success) {
      print("✅ Musik berhasil ditambahkan.");
      _loadCategories(); // Refresh UI
    } else {
      print("❌ Gagal menambahkan musik.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kategori Musik")),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final entry = _categories.entries.elementAt(index);
                  return ListTile(
                    title: Text(entry.value['name'] ?? 'Unknown'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap:
                        () =>
                            _navigateToCategory(entry.key, entry.value['name']),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMusicDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
