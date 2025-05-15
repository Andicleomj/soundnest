import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class MusikKategoriScreen extends StatefulWidget {
  const MusikKategoriScreen({Key? key}) : super(key: key);

  @override
  State<MusikKategoriScreen> createState() => _MusikKategoriScreenState();
}

class _MusikKategoriScreenState extends State<MusikKategoriScreen> {
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
    print('Snapshot: ${snapshot.value}');

    if (snapshot.exists && snapshot.value is Map) {
      setState(() {
        _categories =
            (snapshot.value as Map).entries
                .map((e) {
                  final value = e.value;
                  if (value is Map && value.containsKey('nama')) {
                    return {
                      'id': e.key.toString(),
                      'nama':
                          value['nama']?.toString() ?? 'Kategori Tanpa Nama',
                    };
                  }
                  return null;
                })
                .whereType<Map<String, String>>()
                .toList();
      });
      print('Categories: $_categories');
    } else {
      setState(() {
        _categories = [];
      });
      print('No Categories Found');
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
            title: Text(category['name'] ?? 'Kategori Tanpa Nama'),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/daftar',
                arguments: {
                  'categoryId': category['id'],
                  'categoryName': category['name'],
                },
              );
            },
          );
        },
      ),
    );
  }
}
