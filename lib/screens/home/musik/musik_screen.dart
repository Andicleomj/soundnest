import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({Key? key}) : super(key: key);

  @override
  _MusicScreenState createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/music/categories',
  );

  List<Map<String, String>> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() async {
    final snapshot = await _dbRef.get();
    if (snapshot.exists && snapshot.value is Map) {
      setState(() {
        _categories =
            (snapshot.value as Map).entries
                .map((e) {
                  final value = e.value;
                  if (value is Map && value.containsKey('nama')) {
                    return {
                      'id': e.key.toString(),
                      'nama': value['nama'] ?? 'Kategori Tanpa Nama',
                    };
                  }
                  return null;
                })
                .whereType<Map<String, String>>()
                .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kategori Musik')),
      body: ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return ListTile(
            title: Text(category['nama'] ?? 'Kategori Tanpa Nama'),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/daftar',
                arguments: {
                  'categoryId': category['id'],
                  'categoryName': category['nama'],
                },
              );
            },
          );
        },
      ),
    );
  }
}
