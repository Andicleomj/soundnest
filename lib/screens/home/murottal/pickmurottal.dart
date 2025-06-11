import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class MurottalPickerScreen extends StatefulWidget {
  const MurottalPickerScreen({super.key});

  @override
  State<MurottalPickerScreen> createState() => _MurottalPickerScreenState();
}

class _MurottalPickerScreenState extends State<MurottalPickerScreen> {
  final DatabaseReference categoryRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/murottal/categories',
  );
  bool isLoading = true;
  Map<String, dynamic> allMurottalData = {};

  @override
  void initState() {
    super.initState();
    fetchAllMurottal();
  }

  Future<void> fetchAllMurottal() async {
    final snapshot = await categoryRef.get();
    if (snapshot.exists) {
      print("Snapshot value: ${snapshot.value}"); // Debug
      final rawData = Map<String, dynamic>.from(snapshot.value as Map);
      Map<String, List<Map<String, dynamic>>> parsedData = {};

      for (final entry in rawData.entries) {
        final categoryData = Map<String, dynamic>.from(entry.value);
        final categoryName = categoryData['nama'] ?? 'Tanpa Nama';
        final files =
            categoryData['files'] != null
                ? Map<String, dynamic>.from(categoryData['files'])
                : {};

        final murottalList =
            files.entries.map((e) {
              final fileData = Map<String, dynamic>.from(e.value);
              return {
                'title': fileData['title'] ?? 'Judul tidak tersedia',
                'fileId': fileData['fileId'] ?? '',
              };
            }).toList();

        parsedData[categoryName] = murottalList;
      }

      setState(() {
        allMurottalData = parsedData;
        isLoading = false;
      });
    } else {
      print('Snapshot tidak ditemukan');
      setState(() {
        allMurottalData = {};
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Pilih Murottal',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : allMurottalData.isEmpty
              ? const Center(child: Text('Tidak ada murottal tersedia'))
              : ListView(
                children:
                    allMurottalData.entries.map((entry) {
                      final categoryName = entry.key;
                      final murottalList =
                          entry.value as List<Map<String, dynamic>>;

                      return ExpansionTile(
                        title: Text(categoryName),
                        children:
                            murottalList.map((murottal) {
                              final title = murottal['title'];
                              final fileId = murottal['fileId'];

                              return ListTile(
                                title: Text(title),
                                onTap: () {
                                  Navigator.pop(context, {
                                    'category': categoryName,
                                    'title': title,
                                    'fileId': fileId,
                                  });
                                },
                              );
                            }).toList(),
                      );
                    }).toList(),
              ),
    );
  }
}
