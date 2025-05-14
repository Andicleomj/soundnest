import 'package:flutter/material.dart';
import 'package:soundnest/screens/home/musik/daftar_musik.dart';
import 'package:soundnest/service/music_service.dart';

class KategoriMusikScreen extends StatefulWidget {
  const KategoriMusikScreen({super.key});

  @override
  State<KategoriMusikScreen> createState() => _KategoriMusikScreenState();
}

class _KategoriMusikScreenState extends State<KategoriMusikScreen> {
  final MusicService _musicService = MusicService();
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() async {
    final loadedCategories = await _musicService.getAllCategories();
    setState(() => categories = loadedCategories);
  }

  void _navigateToAddCategory() {
    Navigator.pushNamed(context, '/add_musik').then((_) => _loadCategories());
  }

  void _navigateToCategory(String categoryId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DaftarMusikScreen(categoryId: categoryId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori Musik'),
        actions: [
          IconButton(
            onPressed: _navigateToAddCategory,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return ListTile(
            title: Text(category['name']),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _navigateToCategory(category['id']),
          );
        },
      ),
    );
  }
}
