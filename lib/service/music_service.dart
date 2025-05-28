// lib/service/music_service.dart
import 'package:firebase_database/firebase_database.dart';

class MusicService {
  final DatabaseReference _musicRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/music/categories',
  );

  /// Menambahkan file musik ke kategori tertentu
  Future<void> addMusic({
    required String category,
    required String title,
    required String fileId,
  }) async {
    try {
      final categoryRef = _musicRef.child('$category/files');
      final newFileRef = categoryRef.push();
      await newFileRef.set({'title': title, 'fileid': fileId});
      print("✅ Musik berhasil ditambahkan.");
    } catch (e) {
      print("❌ Error menambahkan musik: $e");
    }
  }

  /// Mendapatkan daftar kategori musik
  Future<List<Map<String, String>>> getCategories() async {
    try {
      final snapshot = await _musicRef.get();
      if (snapshot.exists && snapshot.value is Map) {
        return (snapshot.value as Map).entries
            .map((e) {
              final value = e.value;
              if (value is Map && value.containsKey('nama')) {
                return {
                  'id': e.key.toString(),
                  'nama': value['nama']?.toString() ?? 'Kategori Tanpa Nama',
                };
              }
              return null;
            })
            .whereType<Map<String, String>>()
            .toList();
      }
    } catch (e) {
      print("❌ Error fetching categories: $e");
    }
    return [];
  }

  /// Mendapatkan daftar musik berdasarkan kategori
  Future<List<Map<String, dynamic>>> getMusicByCategory(
    String categoryId,
  ) async {
    try {
      final categoryRef = _musicRef.child('$categoryId/files');
      final snapshot = await categoryRef.get();
      if (snapshot.exists && snapshot.value is Map) {
        final files = Map<String, dynamic>.from(snapshot.value as Map);
        return files.entries.map((entry) {
          final file = entry.value;
          return {
            'id': entry.key,
            'title': file['title'] ?? 'Unknown Title',
            'fileid': file['fileid'] ?? '',
          };
        }).toList();
      }
    } catch (e) {
      print("❌ Error fetching music: $e");
    }
    return [];
  }
}