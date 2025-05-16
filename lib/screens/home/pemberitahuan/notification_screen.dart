import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _toggleListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          print('Status: $val');
          if (val == 'done' || val == 'notListening') {
            setState(() {
              _isListening = false;
              _text = ""; // Hapus teks saat selesai berbicara
            });
          }
        },
        onError: (val) => print('Error: $val'),
      );
      if (available) {
        setState(() {
          _isListening = true;
          _text = ""; // Reset teks saat mulai
        });
        _speech.listen(
          onResult: (val) {
            if (val.recognizedWords.isNotEmpty) {
              setState(() {
                _text = val.recognizedWords;
              });
            }
          },
        );
      }
    } else {
      setState(() {
        _isListening = false;
        _text = ""; // Hapus teks saat tombol mic ditekan lagi
      });
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Pemberitahuan",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20), // Lebih tinggi agar logo ke atas
          Center(
            child: Image.asset(
              'assets/Logo 1.png',
              width: 200,
              height: 200,
            ),
          ),
          const SizedBox(height: 30),
          if (_text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _text,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          const Spacer(),
          GestureDetector(
            onTap: _toggleListening,
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mic,
                    size: 55,
                    color: _isListening ? Colors.red : Colors.blue,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _isListening
                      ? "Sedang mendengarkan..."
                      : "Klik untuk mulai bicara",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
