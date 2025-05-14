import 'package:flutter/material.dart';
import 'package:soundnest/service/music_player_service.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  _MusicScreenState createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final MusicPlayerService _musicPlayerService = MusicPlayerService();

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Masa Adaptasi Sekolah', 'files': []},
    {'name': 'Aku Suka Olahraga', 'files': []},
  ];

  void _addCategory(String name) {
    setState(() {
      _categories.add({'name': name, 'files': []});
    });
  }

  void _addMusic(int index, String title, String fileId) {
    setState(() {
      _categories[index]['files'].add({'title': title, 'file_id': fileId});
    });
  }

  void _playMusic(String fileId) async {
    await _musicPlayerService.playMusicFromProxy(fileId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Ganti background jadi putih
      appBar: AppBar(
        title: const Text('Kategori Musik'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(_categories[index]['name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._categories[index]['files'].map<Widget>((file) {
                    return ListTile(
                      title: Text(file['title']),
                      trailing: IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () => _playMusic(file['file_id']),
                      ),
                    );
                  }).toList(),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddMusicDialog(index),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddCategoryDialog() {
    String newCategory = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Kategori'),
        content: TextField(
          onChanged: (value) => newCategory = value,
          decoration: const InputDecoration(hintText: 'Nama Kategori'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (newCategory.isNotEmpty) _addCategory(newCategory);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _showAddMusicDialog(int index) {
    String title = '';
    String fileId = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Musik'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) => title = value,
              decoration: const InputDecoration(hintText: 'Judul Musik'),
            ),
            TextField(
              onChanged: (value) => fileId = value,
              decoration: const InputDecoration(
                hintText: 'File ID Google Drive',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (title.isNotEmpty && fileId.isNotEmpty) {
                _addMusic(index, title, fileId);
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}
