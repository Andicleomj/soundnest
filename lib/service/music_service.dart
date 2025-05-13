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
  final categoryId = uuid.v4(); // UUID otomatis untuk kategori
  final fileIdUuid = uuid.v4(); // UUID otomatis untuk file

  await musicRef.child(categoryId).set({
    'name': category,
    'files': {
      fileIdUuid: {'title': title, 'file_id': fileId},
    },
  });
}
