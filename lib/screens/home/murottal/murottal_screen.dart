import 'package:flutter/material.dart';
import 'package:soundnest/screens/home/murottal/surah_screen.dart';
import 'package:soundnest/screens/home/murottal/ayat_kursi.dart';

class MurottalScreen extends StatelessWidget {
  const MurottalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
    children: [
      // Background Image
      Positioned.fill(
        child: Image.asset(
          'assets/alquran.jpg',
          fit: BoxFit.cover,
        ),
      ), 
    Scaffold(
      backgroundColor: Colors.transparent,
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
        padding: const EdgeInsets.all(15.0),
        child: GridView.count(
          crossAxisCount: 1,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 8,
          children: [
            _buildCategoryCard(context, 'Surah Pendek'),
            _buildCategoryCard(context, 'Ayat Kursi'),
          ],
        ),
      ),
    ),
    ],
    );
  }

  Widget _buildCategoryCard(BuildContext context, String category) {
    return GestureDetector(
      onTap: () {
        if (category == 'Ayat Kursi') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AyatKursi(
                categoryPath:
                    'devices/devices_01/murottal/categories/Kategori_2/files',
                categoryName: category,
              ),
            ),
          );
        } else {
          // Default ke Surah Pendek
          final path =
              'devices/devices_01/murottal/categories/Kategori_1/files';
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SurahScreen(categoryPath: path, categoryName: category),
            ),
          );
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.blue.shade100, 
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Text(
            category,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      ),
    );
  }
}
