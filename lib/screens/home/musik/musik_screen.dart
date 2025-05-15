import 'package:flutter/material.dart';
import 'package:soundnest/screens/home/musik/Olahraga_screen.dart';
import 'package:soundnest/screens/home/musik/hewan_screen.dart';
import 'package:soundnest/screens/home/musik/kendaraan_screen.dart';
import 'package:soundnest/screens/home/musik/profesi_screen.dart';
import 'package:soundnest/screens/home/musik/adaptasi_screen.dart';
import 'package:soundnest/screens/home/musik/family_screen.dart';
import 'package:soundnest/screens/home/musik/bumi_screen.dart';
import 'package:soundnest/screens/home/musik/hari_screen.dart';
import 'package:soundnest/screens/home/musik/ramadhan_screen.dart';
import 'package:soundnest/screens/home/musik/haji_screen.dart';
import 'package:soundnest/screens/home/musik/mama_screen.dart';
import 'package:soundnest/screens/home/musik/sunda_screen.dart';
import 'package:soundnest/screens/home/musik/guru_screen.dart';

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
        return ' Kategori tidak ditemukan';
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

  // Fungsi navigasi dinamis
  void navigateToCategoryScreen(BuildContext context, String category) {
    String categoryPath;
    Widget screen;

    switch (category) {
      case 'Hewan':
        categoryPath = 'devices/devices_01/music/categories/kategori_001/files';
        screen = HewanScreen(
          categoryPath: categoryPath,
          categoryName: category,
        );
        break;
      case 'Kendaraan':
        categoryPath = 'devices/devices_01/music/categories/kategori_002/files';
        screen = KendaraanScreen(
          categoryPath: categoryPath,
          categoryName: category,
        );
        break;
      case 'Aku Suka Olahraga':
        categoryPath = 'devices/devices_01/music/categories/kategori_003/files';
        screen = OlahragaScreen(
          categoryPath: categoryPath,
          categoryName: category,
        );
        break;
      case 'Profesi':
        categoryPath = 'devices/devices_01/music/categories/kategori_013/files';
        screen = ProfesiScreen(
          categoryPath: categoryPath,
          categoryName: category,
        );
        break;
      case 'Masa Adaptasi Sekolah':
        categoryPath = 'devices/devices_01/music/categories/kategori_004/files';
        screen = AdaptasiScreen(
          categoryPath: categoryPath,
          categoryName: category,
        );
        break;
      case 'My Family':
        categoryPath = 'devices/devices_01/music/categories/kategori_005/files';
        screen = FamilyScreen(
          categoryPath: categoryPath,
          categoryName: category,
        );
        break;
      case 'Bumi Planet':
        categoryPath = 'devices/devices_01/music/categories/kategori_006/files';
        screen = BumiScreen(categoryPath: categoryPath, categoryName: category);
        break;
      case 'Hari Kemerdekaan':
        categoryPath = 'devices/devices_01/music/categories/kategori_007/files';
        screen = HariScreen(categoryPath: categoryPath, categoryName: category);
        break;
      case 'Ramadhan':
        categoryPath = 'devices/devices_01/music/categories/kategori_008/files';
        screen = RamadhanScreen(
          categoryPath: categoryPath,
          categoryName: category,
        );
        break;
      case 'Manasik Haji':
        categoryPath = 'devices/devices_01/music/categories/kategori_009/files';
        screen = HajiScreen(categoryPath: categoryPath, categoryName: category);
        break;
      case 'Mother Day':
        categoryPath = 'devices/devices_01/music/categories/kategori_010/files';
        screen = MamaScreen(categoryPath: categoryPath, categoryName: category);
        break;
      case 'Budaya Sunda':
        categoryPath = 'devices/devices_01/music/categories/kategori_011/files';
        screen = SundaScreen(
          categoryPath: categoryPath,
          categoryName: category,
        );
        break;
      case 'Guruku Tersayang':
        categoryPath = 'devices/devices_01/music/categories/kategori_012/files';
        screen = GuruScreen(categoryPath: categoryPath, categoryName: category);
        break;

      default:
        throw Exception('Kategori tidak dikenal: $category');
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  // Widget _buildCategoryCard yang lebih singkat
  Widget _buildCategoryCard(BuildContext context, String category) {
    return GestureDetector(
      onTap: () => navigateToCategoryScreen(context, category),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
