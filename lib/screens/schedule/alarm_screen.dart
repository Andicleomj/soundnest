import 'dart:async';
import 'package:flutter/material.dart';
import 'package:soundnest/service/music_player_service.dart';
import 'package:soundnest/models/alarmschedule.dart';

class AlarmPlayScreen extends StatefulWidget {
  final AlarmSchedule alarm;
  final VoidCallback onStop;
  final MusicPlayerService musicPlayerService;

  final String? audioUrl;
  final List<String>? audioUrls;

  const AlarmPlayScreen({
    super.key,
    required this.alarm,
    required this.onStop,
    required this.musicPlayerService,
    this.audioUrl,
    this.audioUrls,
  }) : assert(
         audioUrl != null || audioUrls != null,
         'Wajib isi salah satu audioUrl atau audioUrls',
       );

  @override
  State<AlarmPlayScreen> createState() => _AlarmPlayScreenState();
}

class _AlarmPlayScreenState extends State<AlarmPlayScreen> {
  late Timer _timer;
  late DateTime _now;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _now = DateTime.now()),
    );

    _startAudio();
  }

  Future<void> _startAudio() async {
    try {
      if (widget.audioUrls != null && widget.audioUrls!.isNotEmpty) {
        await _playPlaylist(widget.audioUrls!);
      } else if (widget.audioUrl != null) {
        await widget.musicPlayerService.playFromFileId(widget.audioUrl!);
      }
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('❌ Error saat memulai audio: $e');
    }
  }

  Future<void> _playPlaylist(List<String> urls) async {
    if (_currentIndex >= urls.length) return;

    try {
      await widget.musicPlayerService.playFromFileId(
        urls[_currentIndex],
        onComplete: () async {
          if (!widget.musicPlayerService.isPlaying) {
            debugPrint("⏸️ Playback dihentikan, tidak lanjut playlist");
            return;
          }
          _currentIndex++;
          if (_currentIndex < urls.length) {
            await _playPlaylist(urls);
          } else {
            if (mounted) Navigator.pop(context);
          }
        },
      );
    } catch (e) {
      debugPrint('❌ Error saat memutar playlist: $e');
    }
  }

  Future<void> _stopAudio() async {
    try {
      await widget.musicPlayerService.stopMusic();
      setState(() => widget.alarm.isActive = false);
      widget.onStop();
    } catch (e) {
      debugPrint('❌ Error saat stop audio: $e');
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = _now;
    final timeStr =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    final dateStr = "${now.day} ${_monthName(now.month)} ${now.year}";

    return Material(
      color: Colors.black,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.alarm_rounded, size: 100, color: Colors.orange),
              const SizedBox(height: 40),
              Text(
                timeStr,
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dateStr,
                style: const TextStyle(fontSize: 20, color: Colors.white70),
              ),
              const SizedBox(height: 20),
              Text(
                widget.alarm.title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _stopAudio,
                  icon: const Icon(Icons.stop_circle_rounded, size: 32),
                  label: const Text("Stop"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 8,
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
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
