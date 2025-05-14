import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class MusikKategoriScreen extends StatefulWidget {
  final String category;

  const MusikKategoriScreen({super.key, required this.category});

  @override
  State<MusikKategoriScreen> createState() => _MusikKategoriScreenState();
}

class _MusikKategoriScreenState extends State<MusikKategoriScreen> {
  final DatabaseReference _musicRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/music/categories',
  );

  Future<void> _addFile() async {
    String? fileId = await _showAddFileDialog();
    if (fileId == null || fileId.isEmpty) return;

    String? fileTitle = await _showAddTitleDialog();
    if (fileTitle == null || fileTitle.isEmpty) fileTitle = "Unknown Title";

    await _musicRef.child(widget.category).child("files").push().set({
      'file_id': fileId,
      'title': fileTitle,
    });
  }

  Future<String?> _showAddFileDialog() async {
    String input = "";
    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Tambah File ID"),
            content: TextField(
              onChanged: (value) => input = value,
              decoration: InputDecoration(hintText: "Masukkan File ID"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Batal"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, input),
                child: Text("Tambah"),
              ),
            ],
          ),
    );
  }

  Future<String?> _showAddTitleDialog() async {
    String input = "";
    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Tambah File Title"),
            content: TextField(
              onChanged: (value) => input = value,
              decoration: InputDecoration(hintText: "Masukkan Judul File"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Batal"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, input),
                child: Text("Tambah"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Musik: ${widget.category}")),
      body: StreamBuilder(
        stream: _musicRef.child(widget.category).child("files").onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final files = Map<String, dynamic>.from(
              snapshot.data!.snapshot.value as Map,
            );
            return ListView(
              children:
                  files.values.map((file) {
                    return ListTile(
                      title: Text(file['title'] ?? 'Unknown Title'),
                      subtitle: Text(file['file_id'] ?? 'No File ID'),
                    );
                  }).toList(),
            );
          }
          return const Center(child: Text("Tidak ada musik."));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFile,
        child: const Icon(Icons.add),
      ),
    );
  }
}
