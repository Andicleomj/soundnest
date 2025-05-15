// daftar_musik.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DaftarMusikScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const DaftarMusikScreen({
    required this.categoryId,
    required this.categoryName,
    Key? key,
  }) : super(key: key);

  @override
  State<DaftarMusikScreen> createState() => _DaftarMusikScreenState();
}

class _DaftarMusikScreenState extends State<DaftarMusikScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  List<Map<String, String>> _musicFiles = [];

  @override
  void initState() {
    super.initState();
    _loadMusicFiles();
  }

  void _loadMusicFiles() async {
    final snapshot =
        await _dbRef
            .child(
              'devices/devices_01/music/categories/${widget.categoryId}/files',
            )
            .get();
    print('Snapshot Music Files: ${snapshot.value}');

    if (snapshot.exists && snapshot.value is Map) {
      setState(() {
        _musicFiles =
            (snapshot.value as Map).entries
                .map((e) {
                  final value = e.value;
                  if (value is Map && value.containsKey('title')) {
                    return {
                      'id': e.key,
                      'title': value['title']?.toString() ?? 'Unknown Title',
                      'file_id': value['file_id']?.toString() ?? '',
                    };
                  }
                  return null;
                })
                .whereType<Map<String, String>>()
                .toList();
      });
    } else {
      setState(() {
        _musicFiles = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName)),
      body:
          _musicFiles.isEmpty
              ? const Center(child: Text('No Music Files Found'))
              : ListView.builder(
                itemCount: _musicFiles.length,
                itemBuilder: (context, index) {
                  final file = _musicFiles[index];
                  return ListTile(
                    title: Text(file['title'] ?? 'Unknown Title'),
                    subtitle: Text(file['file_id'] ?? ''),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/add',
            arguments: {'categoryId': widget.categoryId},
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
