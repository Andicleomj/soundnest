import 'package:flutter/material.dart';

class MusikKategoriScreen extends StatelessWidget {
  const MusikKategoriScreen({super.key});

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
            _buildCategoryCard(context, 'Kebersamaan'),
            _buildCategoryCard(context, 'Cinta Tanah Air'),
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
            builder: (context) => DaftarMusikScreen(category: category),
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

class DaftarMusikScreen extends StatelessWidget {
  final String category;

  const DaftarMusikScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Musik - $category'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text('Daftar musik untuk $category akan ditampilkan di sini.'),
      ),
    );
  }
}
