import 'dart:async';
import 'package:flutter/material.dart';

class AlarmPlayScreen extends StatefulWidget {
  final String title;
  final String audioUrl;
  final VoidCallback onResume;
  final VoidCallback onStop;

  const AlarmPlayScreen({
    super.key,
    required this.title,
    required this.audioUrl,
    required this.onResume,
    required this.onStop,
  });

  @override
  State<AlarmPlayScreen> createState() => _AlarmPlayScreenState();
}

class _AlarmPlayScreenState extends State<AlarmPlayScreen> {
  late Timer _timer;
  late DateTime _now;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      () {
            setState(() => _now = DateTime.now());
          }
          as void Function(Timer timer),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      widget.onResume();
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeString =
        "${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}";
    final dateString = "${_now.day} ${_monthName(_now.month)} ${_now.year}";

    return Material(
      color: Colors.black, // ini override semua warna latar belakang
      child: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black, // pastikan full hitam
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
                  color: Colors.black,
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
                  color: Colors.black,
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
                      onPressed: widget.onStop,
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
