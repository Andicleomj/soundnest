import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'alarm_audio_controller.dart';

class AlarmPlayScreen extends StatefulWidget {
  final String title;
  final String audioUrl;
  final AlarmAudioController audioController;
  final VoidCallback onResume;
  final VoidCallback onStop;

  const AlarmPlayScreen({
    super.key,
    required this.title,
    required this.audioUrl,
    required this.audioController,
    required this.onResume,
    required this.onStop,
  });

  @override
  State<AlarmPlayScreen> createState() => _AlarmPlayScreenState();
}

class _AlarmPlayScreenState extends State<AlarmPlayScreen> {
  late Timer _timer;
  late DateTime _now;
  bool _isPlaying = true;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        _now = DateTime.now();
      });
    });
    _startAudio(); // mulai saat layar terbuka
  }

  Future<void> _startAudio() async {
    try {
      await widget.audioController.setUrl(widget.audioUrl);
      await widget.audioController.play();
      setState(() {
        _isPlaying = true;
      });
    } catch (e) {
      debugPrint('Error loading audio: $e');
    }
  }

  void _togglePlayPause() async {
    if (!_isPlaying) {
      await widget.audioController.seekToStart();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
    if (_isPlaying) {
      await widget.audioController.play();
      widget.onResume();
    } else {
      await widget.audioController.pause();
    }
  }

  void _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
    });
    widget.onStop();
  }

  @override
  void dispose() {
    _timer.cancel();
    widget.audioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeString =
        "${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}";
    final dateString = "${_now.day} ${_monthName(_now.month)} ${_now.year}";

    return Material(
      color: Colors.black,
      child: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.alarm_rounded, size: 100, color: Colors.orange),
              const SizedBox(height: 40),
              Text(
                timeString,
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color:
                      Colors
                          .white, // sebelumnya hitam, jadi tidak terlihat di latar hitam
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dateString,
                style: const TextStyle(fontSize: 20, color: Colors.white70),
              ),
              const SizedBox(height: 20),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _togglePlayPause,
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                      label: Text(_isPlaying ? "Jeda" : "Lanjutkan"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _stopAudio,
                      icon: const Icon(Icons.stop),
                      label: const Text("Stop"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[month - 1];
  }
}
