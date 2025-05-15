// add_musik.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AddMusikScreen extends StatefulWidget {
  final String categoryId;

  const AddMusikScreen({required this.categoryId, Key? key}) : super(key: key);

  @override
  State<AddMusikScreen> createState() => _AddMusikScreenState();
}

class _AddMusikScreenState extends State<AddMusikScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _fileIdController = TextEditingController();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  void _addMusicFile() async {
    final title = _titleController.text.trim();
    final fileId = _fileIdController.text.trim();

    if (title.isEmpty || fileId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title dan File ID tidak boleh kosong")),
      );
      return;
    }

    await _dbRef
        .child('devices/devices_01/music/categories/${widget.categoryId}/files')
        .push()
        .set({'title': title, 'file_id': fileId});

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Musik")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: _fileIdController,
              decoration: const InputDecoration(labelText: "File ID"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addMusicFile,
              child: const Text("Tambahkan Musik"),
            ),
          ],
        ),
      ),
    );
  }
}
