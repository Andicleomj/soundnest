import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class BellScreen extends StatefulWidget {
  const BellScreen({super.key});

  @override
  State<BellScreen> createState() => _BellScreenState();
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
      backgroundColor: Colors.white, // Set background putih
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Bel",
          style: TextStyle(
            fontSize: 22,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // Card bel
            Expanded(
              child: Center(
                child: Container(
                  width: 250,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 145, 204, 233),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent,
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.notifications_active_rounded,
                        size: 80,
                        color: Colors.black87,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _playBellSound,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                        ),
                        child: const Text(
                          "Bunyikan Bel",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Klik tombol untuk membunyikan bel.\nPastikan volume aktif.",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),
            const Text(
              "📢 Tetap semangat dan disiplin waktu!",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
