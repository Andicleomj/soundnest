import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _isRecording = false;

  static const platform = MethodChannel('com.example.soundnest/audio');

  @override
  void initState() {
    super.initState();
    _requestPermissions();
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
    print("Calling startMicLoop...");
    try {
      await platform.invokeMethod('startMicLoop');
      print("startMicLoop called");
    } catch (e) {
      print("Start error: $e");
    }
  }

  Future<void> _stopMicLoop() async {
    print("Calling stopMicLoop...");
    try {
      await platform.invokeMethod('stopMicLoop');
      print("stopMicLoop called");
    } catch (e) {
      print("Stop error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Mic to Speaker", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isRecording ? Icons.mic : Icons.mic_none,
              size: 100,
              color: _isRecording ? Colors.red : Colors.grey,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
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
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: _isRecording ? Colors.red : Colors.blue,
              ),
              child: Text(_isRecording ? "Stop" : "Mulai Rekam"),
            ),
            const SizedBox(height: 20),
            const Text(
              "Suara dari mic akan langsung diputar di speaker",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
