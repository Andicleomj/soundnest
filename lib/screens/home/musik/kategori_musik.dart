import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class MusikKategoriScreen extends StatelessWidget {
  final String category;

  const MusikKategoriScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final DatabaseReference filesRef = FirebaseDatabase.instance.ref(
      'devices/devices_01/music/categories/$category/files',
    );

    return Scaffold(
      appBar: AppBar(title: Text("Musik: $category")),
      body: StreamBuilder(
        stream: filesRef.onValue,
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
    );
  }
}
