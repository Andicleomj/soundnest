import 'package:firebase_database/firebase_database.dart';

class MusicService {
  final DatabaseReference _musicRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/music/categories',
  );

  Future<List<Map<String, dynamic>>> getMusicByCategory(
    String categoryId,
  ) async {
    try {
      final categoryRef = _musicRef.child('$categoryId/files');
      final snapshot = await categoryRef.get();
      if (snapshot.exists) {
        final files = Map<String, dynamic>.from(snapshot.value as Map);
        return files.values.map((file) {
          return {
            'title': file['title'] ?? 'Unknown Title',
            'file_id': file['file_id'] ?? '',
          };
        }).toList();
      }
    } catch (e) {
      print("❌ Error fetching music: $e");
    }
    return [];
  }
}
