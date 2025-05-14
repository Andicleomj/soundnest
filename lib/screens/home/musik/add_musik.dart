import 'package:flutter/material.dart';
import 'package:soundnest/service/music_service.dart'; // Import service yang sudah kita buat

class AddMusicScreen extends StatelessWidget {
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController fileIdController = TextEditingController();

  AddMusicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Musik')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Kategori Musik'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Judul Musik'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: fileIdController,
              decoration: const InputDecoration(
                labelText: 'File ID (Google Drive)',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await addMusic(
                  category: categoryController.text,
                  title: titleController.text,
                  fileId: fileIdController.text,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Musik berhasil ditambahkan!')),
                );
                Navigator.pop(context);
              },
              child: const Text('Simpan Musik'),
            ),
          ],
        ),
      ),
    );
  }
}
