import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';

class JadwalSurahService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('jadwal_surah');
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timer;

  void startChecking() {
    _timer = Timer.periodic(Duration(minutes: 1), (_) async {
      final now = DateFormat('HH:mm').format(DateTime.now());
      final snapshot = await _dbRef.get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        for (var item in data.values) {
          if (item['jam'] == now) {
            final fileId = item['fileId'];
            final url = 'http://localhost:3000/stream/$fileId';
            print('Memutar: $url');
            try {
              await _audioPlayer.play(UrlSource(url));
            } catch (e) {
              print('❌ Gagal memutar audio: $e');
            }
          }
        }
      }
    });
  }

  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
  }
}
