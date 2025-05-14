import 'package:flutter/material.dart';
import 'package:soundnest/service/music_service.dart'; // Import service yang sudah kita buat

class AddMusicScreen extends StatelessWidget {
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController fileIdController = TextEditingController();
  final MusicService musicService =
      MusicService(); // Buat instance MusicService

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
                if (categoryController.text.isEmpty ||
                    titleController.text.isEmpty ||
                    fileIdController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Semua field harus diisi!')),
                  );
                  return;
                }

                try {
                  await musicService.addMusic(
                    category: categoryController.text.trim(),
                    title: titleController.text.trim(),
                    fileId: fileIdController.text.trim(),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Musik berhasil ditambahkan!'),
                    ),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gagal menambahkan musik.')),
                  );
                }
              },
              child: const Text('Simpan Musik'),
            ),
          ],
        ),
      ),
    );
  }
}
