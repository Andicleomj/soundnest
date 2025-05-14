// lib/service/music_service.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';

class MusicService {
  final DatabaseReference musicRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/music/categories',
  );

  final Uuid _uuid = Uuid();

  Future<void> addCategory(String categoryName) async {
    final snapshot = await musicRef.get();
    final categories = (snapshot.value as Map<dynamic, dynamic>? ?? {});

    // Cek apakah kategori sudah ada
    if (categories.values.any((cat) => cat['name'] == categoryName)) {
      print("⚠️ Kategori sudah ada");
      return;
    }

    // Tambahkan kategori baru dengan UUID sebagai ID
    final newCategoryId = _uuid.v4();
    await musicRef.child(newCategoryId).set({
      'name': categoryName,
      'files': {},
    });

    print("✅ Kategori berhasil ditambahkan ke Firebase");
  }

  Future<void> addMusic({
    required String category,
    required String title,
    required String fileId,
  }) async {
    final snapshot = await musicRef.get();
    final categories = (snapshot.value as Map<dynamic, dynamic>? ?? {});

    // Cari ID kategori atau buat kategori baru
    String? categoryId =
        categories.entries
            .firstWhere(
              (entry) => entry.value['name'] == category,
              orElse: () {
                final newCategoryId = _uuid.v4();
                musicRef.child(newCategoryId).set({
                  'name': category,
                  'files': {},
                });
                print("✅ Kategori baru dibuat: $category");
                return MapEntry(newCategoryId, {'name': category, 'files': {}});
              },
            )
            .key;

    // Tambahkan musik ke kategori dalam node files
    final newFileId = _uuid.v4();
    await musicRef.child('$categoryId/files/$newFileId').set({
      'title': title,
      'file_id': fileId,
    });

    print("✅ Musik berhasil ditambahkan ke kategori: $category");
  }
}
