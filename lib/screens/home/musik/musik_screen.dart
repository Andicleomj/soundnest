import 'package:flutter/material.dart';
import 'package:soundnest/screens/home/musik/hewan_screen.dart';

class MusicScreen extends StatelessWidget {
  const MusicScreen({super.key});

  String getPathFromCategory(String category) {
    switch (category) {
      case 'Masa Adaptasi Sekolah':
        return 'Masa Adaptasi Sekolah';
      case 'Aku Suka Olahraga':
        return 'Aku Suka Olahraga';
      case 'My Family':
        return 'My Family';
      case 'Bumi Planet':
        return 'Bumi Planet';
      case 'Hari Kemerdekaan':
        return 'Hari Kemerdekaan';
      case 'Ramadhan':
        return 'Ramadhan';
      case 'Hewan':
        return 'Hewan';
      case 'Manasik Haji':
        return 'Manasik Haji';
      case 'Budaya Sunda':
        return 'Budaya Sunda';
      case 'Batik':
        return 'Batik';
      case 'Mother Day':
        return 'Mother Day';
      case 'Guruku Tersayang':
        return 'Guruku Tersayang';
      case 'Profesi':
        return 'Profesi';
      case 'Kendaraan':
        return 'Kendaraan';
      default:
        return 'Surah Pendek';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Kategori Musik',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildCategoryCard(context, 'Masa Adaptasi Sekolah'),
            _buildCategoryCard(context, 'Aku Suka Olahraga'),
            _buildCategoryCard(context, 'My Family'),
            _buildCategoryCard(context, 'Bumi Planet'),
            _buildCategoryCard(context, 'Hari Kemerdekaan'),
            _buildCategoryCard(context, 'Ramadhan'),
            _buildCategoryCard(context, 'Hewan'),
            _buildCategoryCard(context, 'Manasik Haji'),
            _buildCategoryCard(context, 'Budaya Sunda'),
            _buildCategoryCard(context, 'Batik'),
            _buildCategoryCard(context, 'Mother Day'),
            _buildCategoryCard(context, 'Guruku Tersayang'),
            _buildCategoryCard(context, 'Profesi'),
            _buildCategoryCard(context, 'Kendaraan'),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String category) {
    return GestureDetector(
      onTap: () {
        final path = getPathFromCategory(category);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    HewanScreen(categoryPath: path, categoryName: category),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Center(
          child: Text(
            category,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class MusicCategoryScreen extends StatelessWidget {
  final String category;

  const MusicCategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category), backgroundColor: Colors.blue),
      body: Center(
        child: Text('Daftar musik untuk $category akan ditampilkan di sini.'),
      ),
    );
  }
}
