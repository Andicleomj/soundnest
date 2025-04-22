import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Word',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyWordEditor(),
    );
  }
}

class MyWordEditor extends ConsumerStatefulWidget {
  @override
  _MyWordEditorState createState() => _MyWordEditorState();
}

class _MyWordEditorState extends ConsumerState<MyWordEditor> {
  TextEditingController _controller = TextEditingController();

  Future<void> _saveFile() async {
    String? filePath = await FilePicker.platform.saveFile(dialogTitle: 'Save your file');
    if (filePath != null) {
      File file = File(filePath);
      await file.writeAsString(_controller.text);
    }
  }

  Future<void> _openFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['txt']);
    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      String content = await file.readAsString();
      setState(() {
        _controller.text = content;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Word'), actions: [
        IconButton(icon: Icon(Icons.folder_open), onPressed: _openFile),
        IconButton(icon: Icon(Icons.save), onPressed: _saveFile),
      ]),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: TextField(
          controller: _controller,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(border: OutlineInputBorder()),
        ),
      ),
    );
  }
}
