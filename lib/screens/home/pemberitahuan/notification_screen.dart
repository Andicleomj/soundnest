import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  static const platform = MethodChannel('com.example.soundnest/audio');

  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
    await Permission.bluetooth.request();
    await Permission.bluetoothConnect.request();
    await Permission.bluetoothAdvertise.request();
    await Permission.bluetoothScan.request();
    await Permission.audio.request();
  }

  Future<void> _startMicLoop() async {
    try {
      await platform.invokeMethod('startMicLoop');
    } catch (e) {
      print("Start error: $e");
    }
  }

  Future<void> _stopMicLoop() async {
    try {
      await platform.invokeMethod('stopMicLoop');
    } catch (e) {
      print("Stop error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Pemberitahuan",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return Container(
                    width: 150 + (_isRecording ? _waveController.value * 30 : 0),
                    height: 150 + (_isRecording ? _waveController.value * 30 : 0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording ? Colors.red.shade100 : Colors.blue.shade100,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        _isRecording ? Icons.mic : Icons.mic_none,
                        size: 60,
                        color: _isRecording ? Colors.red : Colors.blueAccent,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: ElevatedButton.icon(
                  key: ValueKey(_isRecording),
                  icon: Icon(
                    _isRecording ? Icons.stop : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  label: Text(
                    _isRecording ? "Hentikan" : "Mulai Rekam",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRecording ? Colors.red : Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 6,
                  ),
                  onPressed: () async {
                    if (_isRecording) {
                      await _stopMicLoop();
                    } else {
                      await _startMicLoop();
                    }
                    setState(() {
                      _isRecording = !_isRecording;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.info_outline, size: 20, color: Colors.black45),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Suara dari mikrofon akan langsung diputar ke speaker Bluetooth atau speaker bawaan.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        height: 1.4,
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
}
