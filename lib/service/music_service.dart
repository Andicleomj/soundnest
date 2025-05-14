import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';

final DatabaseReference musicRef = FirebaseDatabase.instance.ref(
  'devices/devices_01/music/categories',
);
final uuid = Uuid();

Future<void> addMusic({
  required String category,
  required String title,
  required String fileId,
}) async {
  // Cek apakah kategori sudah ada
  final snapshot = await musicRef.once();
  Map<dynamic, dynamic>? categories =
      snapshot.snapshot.value as Map<dynamic, dynamic>?;

  String categoryId = '';

  if (categories != null) {
    // Cek apakah kategori sudah ada di Firebase
    categories.forEach((key, value) {
      if (value['name'] == category) {
        categoryId = key;
      }
    });
  }

  // Jika kategori belum ada, buat kategori baru dengan UUID
  if (categoryId.isEmpty) {
    categoryId = uuid.v4();
    await musicRef.child(categoryId).set({'name': category, 'files': {}});
  }

  // Tambahkan file musik ke kategori yang sudah ada atau baru
  final fileIdUuid = uuid.v4();
  await musicRef.child(categoryId).child('files').child(fileIdUuid).set({
    'title': title,
    'file_id': fileId,
  });
}
