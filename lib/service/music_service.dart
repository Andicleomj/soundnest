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
  final snapshot = await musicRef.once();
  final categories = snapshot.snapshot.value as Map<dynamic, dynamic>? ?? {};

  String? categoryId;

  // Cek apakah kategori sudah ada
  categories.forEach((key, value) {
    if (value['name'] == category) {
      categoryId = key;
    }
  });

  if (categoryId == null) {
    // Buat kategori baru jika tidak ada
    categoryId = uuid.v4();
    await musicRef.child(categoryId).set({'name': category, 'files': {}});
  }

  // Tambahkan file musik ke kategori
  final fileIdUuid = uuid.v4();
  await musicRef.child(categoryId).child('files').child(fileIdUuid).set({
    'title': title,
    'file_id': fileId,
  });
}
