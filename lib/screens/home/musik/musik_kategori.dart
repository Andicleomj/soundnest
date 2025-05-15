import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class MusikKategoriScreen extends StatefulWidget {
  final String kategori;

  const MusikKategoriScreen({Key? key, required this.kategori})
    : super(key: key);

  @override
  _MusikKategoriScreenState createState() => _MusikKategoriScreenState();
}

class _MusikKategoriScreenState extends State<MusikKategoriScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _fileIdController = TextEditingController();

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('music');

  void _addMusic() {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();
      final fileId = _fileIdController.text.trim();

      _dbRef
          .child(widget.kategori)
          .push()
          .set({'title': title, 'file_id': fileId})
          .then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Musik berhasil ditambahkan.')),
            );
            _titleController.clear();
            _fileIdController.clear();
          })
          .catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal menambahkan musik: $error')),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Musik - ${widget.kategori}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tambah Musik untuk ${widget.kategori}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: 'Judul Musik'),
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Judul tidak boleh kosong' : null,
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _fileIdController,
                    decoration: InputDecoration(
                      labelText: 'File ID (Google Drive)',
                    ),
                    validator:
                        (value) =>
                            value!.isEmpty
                                ? 'File ID tidak boleh kosong'
                                : null,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addMusic,
                    child: const Text('Tambahkan Musik'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
