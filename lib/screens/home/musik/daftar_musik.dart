import 'package:flutter/material.dart';
import 'package:soundnest/service/music_service.dart';

class DaftarMusikScreen extends StatefulWidget {
  final String categoryId;

  const DaftarMusikScreen({super.key, required this.categoryId});

  @override
  State<DaftarMusikScreen> createState() => _DaftarMusikScreenState();
}

class _DaftarMusikScreenState extends State<DaftarMusikScreen> {
  final MusicService _musicService = MusicService();
  List<Map<String, dynamic>> musicList = [];

  @override
  void initState() {
    super.initState();
    _loadMusic();
  }

  void _loadMusic() async {
    final loadedMusic = await _musicService.getMusicByCategory(
      widget.categoryId,
    );
    setState(() => musicList = loadedMusic);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Musik')),
      body: ListView.builder(
        itemCount: musicList.length,
        itemBuilder: (context, index) {
          final music = musicList[index];
          return ListTile(
            title: Text(music['title']),
            trailing: const Icon(Icons.play_arrow),
            onTap: () {
              // Logika play music menggunakan proxy
            },
          );
        },
      ),
    );
  }
}
