import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DaftarMusikScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const DaftarMusikScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  _DaftarMusikScreenState createState() => _DaftarMusikScreenState();
}

class _DaftarMusikScreenState extends State<DaftarMusikScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/music/categories',
  );

  List<Map<String, String>> _musicList = [];

  @override
  void initState() {
    super.initState();
    _loadMusicList();
  }

  void _loadMusicList() async {
    final snapshot = await _dbRef.child(widget.categoryId).child('files').get();
    if (snapshot.exists) {
      final data = (snapshot.value as Map).values;
      setState(() {
        _musicList =
            data
                .map<Map<String, String>>(
                  (e) => {'title': e['title'], 'fileid': e['fileid']},
                )
                .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Musik - ${widget.categoryName}')),
      body: ListView.builder(
        itemCount: _musicList.length,
        itemBuilder: (context, index) {
          final music = _musicList[index];
          return ListTile(
            title: Text(music['title'] ?? 'Judul Tidak Diketahui'),
            subtitle: Text('File ID: ${music['fileid']}'),
          );
        },
      ),
    );
  }
}
