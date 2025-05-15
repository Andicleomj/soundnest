import 'package:flutter/material.dart';

class MusicScreen extends StatelessWidget {
  const MusicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori Musik'),
        backgroundColor: Colors.blue,
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
            _buildCategoryCard(context, 'Kendariaan'),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MusicCategoryScreen(category: category),
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
