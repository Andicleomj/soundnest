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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Bel",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Klik untuk membunyikan bel",
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
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
