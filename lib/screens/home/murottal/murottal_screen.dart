import 'package:flutter/material.dart';
import 'package:soundnest/screens/home/murottal/surah_screen.dart';

class MurottalScreen extends StatelessWidget {
  const MurottalScreen({Key? key}) : super(key: key);

  String getPathFromCategory(String category) {
    switch (category) {
      case 'Surah Pendek':
        return 'Surah Pendek'; 
      case 'Ayat Kursi':
        return 'Ayat Kursi';
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
          'Kategori Murottal',
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
            _buildCategoryCard(context, 'Surah Pendek'),
            _buildCategoryCard(context, 'Ayat Kursi'),
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
                    SurahScreen(categoryPath: path, categoryName: category),
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
