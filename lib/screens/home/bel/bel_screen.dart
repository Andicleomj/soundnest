import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class BellScreen extends StatefulWidget {
  const BellScreen({super.key});

  @override
  _BellScreenState createState() => _BellScreenState();
}

class _BellScreenState extends State<BellScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  void _playBellSound() async {
  await _audioPlayer.setSourceAsset('sounds/bell.mp3');
  await _audioPlayer.resume();
}

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bel"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Klik untuk membunyikan bel",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _playBellSound,
              child: const Icon(
                Icons.notifications,
                size: 100,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
