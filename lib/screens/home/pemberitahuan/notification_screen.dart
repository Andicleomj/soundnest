import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "";

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      lowerBound: 0.9,
      upperBound: 1.1,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _pulseController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _pulseController.forward();
        }
      });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            setState(() {
              _isListening = false;
              _text = "";
            });
            _pulseController.stop();
            _pulseController.reset();
          }
        },
        onError: (val) => print('Error: $val'),
      );
      if (available) {
        setState(() {
          _isListening = true;
          _text = "";
        });
        _pulseController.forward();
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
        _text = "";
      });
      _pulseController.stop();
      _pulseController.reset();
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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: 1.1,
          ),
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
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo polos, simple tanpa dekorasi
              Image.asset(
                'assets/Logo 1.png',
                width: 180,
                height: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40),

              // Speech text display box
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _text.isNotEmpty
                    ? Container(
                        key: const ValueKey('textBox'),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.blueAccent,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Text(
                          _text,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Container(
                        key: const ValueKey('placeholder'),
                        height: 70,
                        alignment: Alignment.center,
                        child: const Text(
                          "Teks hasil suara akan tampil di sini",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
              ),

              const Spacer(),

              // Mic button with pulse animation (tetap sama)
              ScaleTransition(
                scale: _pulseController,
                child: GestureDetector(
                  onTap: _toggleListening,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: _isListening
                          ? Colors.redAccent
                          : Colors.grey.shade300,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _isListening
                              ? Colors.redAccent.withOpacity(0.6)
                              : Colors.black12,
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.mic,
                      size: 60,
                      color: _isListening ? Colors.white : Colors.blueAccent,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                _isListening ? "Sedang mendengarkan..." : "Klik untuk mulai bicara",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
