import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

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
            (context) => MusicListScreen(
              categoryId: categoryId,
              categoryName: categoryName,
            ),
      ),
    );
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
    );
  }
}

class MusicListScreen extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  const MusicListScreen({
    required this.categoryId,
    required this.categoryName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final DatabaseReference filesRef = FirebaseDatabase.instance.ref(
      'devices/devices_01/music/categories/$categoryId/files',
    );

    return Scaffold(
      appBar: AppBar(title: Text("Musik dari $categoryName")),
      body: StreamBuilder(
        stream: filesRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final files = Map<String, dynamic>.from(
              snapshot.data!.snapshot.value as Map,
            );
            return ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files.values.elementAt(index);
                return ListTile(
                  title: Text(file['title'] ?? 'Unknown Title'),
                  subtitle: Text(file['file_id'] ?? 'No File ID'),
                );
              },
            );
          }

          return const Center(child: Text("Tidak ada musik."));
        },
      ),
    );
  }
}
