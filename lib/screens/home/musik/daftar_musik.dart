// lib/screens/home/musik/daftar_musik.dart

import 'package:flutter/material.dart';
import 'package:soundnest/service/music_service.dart';

class DaftarMusikScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const DaftarMusikScreen({
    required this.categoryId,
    required this.categoryName,
  });

  @override
  _DaftarMusikScreenState createState() => _DaftarMusikScreenState();
}

class _DaftarMusikScreenState extends State<DaftarMusikScreen> {
  final MusicService _musicService = MusicService();
  List<Map<String, dynamic>> musicList = [];

  @override
  void initState() {
    super.initState();
    loadMusic();
  }

  Future<void> loadMusic() async {
    final loadedMusic = await _musicService.getMusicByCategory(
      widget.categoryId,
    );
    setState(() {
      musicList = loadedMusic;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Musik - ${widget.categoryName}")),
      body: ListView.builder(
        itemCount: musicList.length,
        itemBuilder: (context, index) {
          final music = musicList[index];
          return ListTile(
            title: Text(music['title']),
            subtitle: Text(music['file_id']),
          );
        },
      ),
    );
  }
}
