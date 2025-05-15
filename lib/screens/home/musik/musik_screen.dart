import 'package:flutter/material.dart';
import 'package:soundnest/screens/home/musik/musik_kategori.dart';

class MusicScreen extends StatelessWidget {
  final List<String> categories = [
    'Masa Adaptasi Sekolah',
    'Hari Besar Nasional',
    'Olahraga',
    'Kesenian',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Kategori Musik')),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(categories[index]),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          MusikKategoriScreen(kategori: categories[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
