import 'package:flutter/material.dart';

class MurottalScreen extends StatelessWidget {
  const MurottalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori Murottal'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildCategoryCard(context, 'Juz Amma'),
            _buildCategoryCard(context, 'Surah Pendek'),
            _buildCategoryCard(context, 'Surah Pilihan'),
            _buildCategoryCard(context, 'Al-Qur\'an Lengkap'),
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
            builder: (context) => MurottalCategoryScreen(category: category),
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

class MurottalCategoryScreen extends StatelessWidget {
  final String category;

  const MurottalCategoryScreen({Key? key, required this.category})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category), backgroundColor: Colors.blue),
      body: Center(
        child: Text(
          'Daftar murottal untuk $category akan ditampilkan di sini.',
        ),
      ),
    );
  }
}
