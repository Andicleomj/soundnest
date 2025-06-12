import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:soundnest/service/music_player_service.dart';
import 'alarm_audio_controller.dart';
import 'package:soundnest/models/alarmschedule.dart'; // sesuaikan path ini

class AlarmPlayScreen extends StatefulWidget {
  final AlarmSchedule alarm;
 final VoidCallback onStop;
final VoidCallback onResume;
final MusicPlayerService musicPlayerService;


  const AlarmPlayScreen({
  super.key,
  required this.alarm,
  required this.onResume,
  required this.onStop,
  required this.musicPlayerService,
});

  @override
  State<AlarmPlayScreen> createState() => _AlarmPlayScreenState();
}

class _AlarmPlayScreenState extends State<AlarmPlayScreen> {
  late Timer _timer;
  late DateTime _now;
  bool _isPlaying = true;

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
    await widget.musicPlayerService.playFromFileId(widget.alarm.audioUrl);
    setState(() {
      _isPlaying = true;
    });
  } catch (e) {
    debugPrint('❌ Error saat memulai audio: $e');
  }
}


 Future<void> _togglePlayPause() async {
  setState(() {
    _isPlaying = !_isPlaying;
  });

  if (_isPlaying) {
    await widget.musicPlayerService.resumeMusic(); // bisa juga play() jika resume tidak ada
    widget.onResume();
  } else {
    await widget.musicPlayerService.pauseMusic();
  }
}


 void _stopAudio() async {
   await widget.musicPlayerService.stopMusic();

  setState(() {
    _isPlaying = false;
    widget.alarm.isActive = false; // Matikan alarm di memori
  });

  // TODO: Simpan perubahan ke database kalau kamu pakai Firebase atau SharedPreferences
  // Contoh: await AlarmService.updateAlarm(widget.alarm);

  Navigator.pop(context); // Tutup layar alarm
}


  @override
  void dispose() {
    _timer.cancel();
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
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dateString,
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
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return months[month - 1];
  }
}
