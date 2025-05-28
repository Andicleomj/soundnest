// lib/service/music_file_management.dart
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';

class MusicFileManagement {
  static final DatabaseReference _musicRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/music/categories',
  );
  static final Uuid _uuid = Uuid();

  static Future<bool> addFileToCategory(
    String categoryId,
    String fileId,
    String title,
  ) async {
    try {
      final fileRef = _musicRef.child('$categoryId/files').push();
      await fileRef.set({'title': title, 'fileid': fileId});
      return true;
    } catch (e) {
      print("❌ Gagal menambahkan musik: $e");
      return false;
    }
  }
}
