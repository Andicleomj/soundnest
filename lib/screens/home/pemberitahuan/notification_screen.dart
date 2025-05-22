import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  bool _isRecording = false;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _recorder.openRecorder();
    _player.openPlayer();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
    await Permission.storage.request();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (!_isRecording) {
      // Start recording
      _filePath = '/sdcard/Download/recorded_voice.aac';
      await _recorder.startRecorder(toFile: _filePath, codec: Codec.aacADTS);
      setState(() {
        _isRecording = true;
      });
    } else {
      // Stop recording
      await _recorder.stopRecorder();
      setState(() {
        _isRecording = false;
      });
      if (_filePath != null) {
        await _player.startPlayer(fromURI: _filePath, codec: Codec.aacADTS);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perekam Suara"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isRecording ? Icons.mic : Icons.mic_none,
              size: 100,
              color: _isRecording ? Colors.red : Colors.grey,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleRecording,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                backgroundColor: _isRecording ? Colors.red : Colors.blue,
              ),
              child: Text(_isRecording ? "Stop & Play" : "Mulai Rekam"),
            ),
            const SizedBox(height: 20),
            const Text(
              "Klik tombol untuk merekam suara\nkemudian akan diputar kembali",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
