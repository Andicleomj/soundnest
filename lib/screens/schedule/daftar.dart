import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:soundnest/service/music_player_service.dart';
import 'package:soundnest/utils/app_routes.dart';
import 'dart:convert';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;
import 'package:soundnest/screens/schedule/alarm_screen.dart';
import 'package:soundnest/models/alarmschedule.dart';
import 'dart:math';

final MusicPlayerService musicPlayerService = MusicPlayerService();

class DaftarJadwalScreen extends StatefulWidget {
  const DaftarJadwalScreen({super.key});

  @override
  _DaftarJadwalScreenState createState() => _DaftarJadwalScreenState();
}

class _DaftarJadwalScreenState extends State<DaftarJadwalScreen> {
  final DatabaseReference _manualRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/schedule/manual',
  );
  final DatabaseReference _otomatisRef = FirebaseDatabase.instance.ref(
    'devices/devices_01/schedule/otomatis',
  );

  List<Map<String, dynamic>> schedules = [];
  bool isLoading = true;

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? currentlyPlayingKey;
  OverlayEntry? _overlayEntry;
  Timer? _timer;
  Map<String, bool> playingStatus = {};

  List<Widget> _buildStars(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final List<Map<String, dynamic>> positions = [
      {'top': 40.0, 'left': 30.0, 'size': 40.0, 'color': Colors.white},
      {
        'top': 80.0,
        'left': screenWidth * 0.7,
        'size': 80.0,
        'color': Colors.yellowAccent,
      },
      {
        'top': 120.0,
        'left': screenWidth * 0.3,
        'size': 12.0,
        'color': Colors.blueAccent,
      },
      {
        'top': screenHeight * 0.3,
        'left': 50.0,
        'size': 40.0,
        'color': Colors.pinkAccent,
      },
      {
        'top': screenHeight * 0.45,
        'left': screenWidth * 0.6,
        'size': 10.0,
        'color': Colors.white,
      },
      {
        'top': screenHeight * 0.65,
        'left': screenWidth * 0.4,
        'size': 40.0,
        'color': Colors.cyanAccent,
      },
      {
        'top': screenHeight * 0.25,
        'left': screenWidth * 0.5,
        'size': 60.0,
        'color': Colors.lightBlueAccent,
      },
      {
        'top': screenHeight * 0.38,
        'left': screenWidth * 0.8,
        'size': 20.0,
        'color': Colors.white,
      },
      {
        'top': screenHeight * 0.5,
        'left': screenWidth * 0.2,
        'size': 60.0,
        'color': Colors.white,
      },
      {
        'top': screenHeight * 0.42,
        'left': screenWidth * 0.6,
        'size': 50.0,
        'color': Colors.white,
      },
      {
        'top': screenHeight * 0.1,
        'left': screenWidth * 0.9,
        'size': 20.0,
        'color': Colors.orange,
      },
      {
        'top': screenHeight * 0.6,
        'left': screenWidth * 0.1,
        'size': 15.0,
        'color': Colors.white,
      },
      {
        'top': screenHeight * 0.75,
        'left': screenWidth * 0.7,
        'size': 50.0,
        'color': Colors.purpleAccent,
      },
      {
        'top': screenHeight * 0.85,
        'left': screenWidth * 0.3,
        'size': 50.0,
        'color': Colors.greenAccent,
      },
    ];

    return positions
        .map(
          (pos) => Positioned(
            top: pos['top'],
            left: pos['left'],
            child: _buildStar(size: pos['size'], color: pos['color']),
          ),
        )
        .toList();
  }

  Widget _buildStar({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.9), color.withOpacity(0.0)],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }

  int currentAudioIndex = 0;
  List<String> currentAudioList = [];
  DateTime? currentEndTime;

  @override
  void initState() {
    super.initState();
    tzData.initializeTimeZones(); // Pastikan timezone ter-inisialisasi
    Timer.periodic(Duration(seconds: 1), (_) => _checkAndTriggerAlarm(context));
    List<Map<String, dynamic>> schedules = [];

    _loadSchedules();
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        currentlyPlayingKey = null;
      });
    });
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _audioPlayer.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _showMiniStatusBar(
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            left: MediaQuery.of(context).size.width * 0.2,
            right: MediaQuery.of(context).size.width * 0.2,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
          ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Overlay.of(context)?.insert(_overlayEntry!);
    });

    Future.delayed(duration, () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  Future<void> _loadSchedules() async {
    setState(() => isLoading = true);

    final manualSnapshot = await _manualRef.get();
    final otomatisSnapshot = await _otomatisRef.get();

    List<Map<String, dynamic>> loadedSchedules = [];

    List<Map<String, dynamic>> parseSnapshot(
      DataSnapshot snapshot,
      String source,
    ) {
      if (!snapshot.exists) return [];

      final data = snapshot.value;
      Map<dynamic, dynamic> dataMap;

      if (data is Map<dynamic, dynamic>) {
        dataMap = data;
      } else if (data is List) {
        dataMap = {
          for (int i = 0; i < data.length; i++)
            if (data[i] != null) i: data[i],
        };
      } else {
        dataMap = {};
      }

      return dataMap.entries.map((entry) {
        try {
          final scheduleRaw = entry.value;
          if (scheduleRaw is! Map) throw Exception("Format jadwal salah");

          final schedule = Map<String, dynamic>.from(scheduleRaw);
          final hariData = schedule['hari'];
          String hari;

          if (hariData is String) {
            hari = hariData;
          } else if (hariData is List) {
            hari = hariData.join(', ');
          } else if (hariData is Map) {
            hari = hariData.values.join(', ');
          } else {
            hari = '-';
          }

          final key = '$source-${entry.key}';
          playingStatus[key] ??= false;

          // Ambil daftar audio
          List<Map<String, dynamic>> itemList = [];
          if (schedule['murottalList'] != null) {
            itemList = List<Map<String, dynamic>>.from(
              (schedule['murottalList'] as List).map(
                (e) => Map<String, dynamic>.from(e),
              ),
            );
          } else if (schedule['musicList'] != null) {
            itemList = List<Map<String, dynamic>>.from(
              (schedule['musicList'] as List).map(
                (e) => Map<String, dynamic>.from(e),
              ),
            );
          } else if (schedule.containsKey('fileId')) {
            // otomatis single audio
            itemList = [
              {
                'fileId': schedule['fileId'],
                'title': schedule['title'] ?? 'Audio Otomatis',
              },
            ];
          }

          final combinedTitles = itemList
              .map((m) => m['title'] ?? '')
              .join(', ');
          final audioUrls =
              itemList
                  .map(
                    (m) =>
                        'https://docs.google.com/uc?export=download&id=${m['fileId']}',
                  )
                  .toList();

          // Estimasi waktu selesai
          final waktuStr = schedule['waktu'] ?? schedule['startTime'] ?? '';
          String? estimatedEndTime;
          if (waktuStr.contains(':')) {
            final parts = waktuStr.split(':');
            final h = int.tryParse(parts[0]) ?? 0;
            final m = int.tryParse(parts[1]) ?? 0;
            final start = DateTime(0, 1, 1, h, m);
            final durasiPerAudio = Duration(minutes: 2); // estimasi
            final end = start.add(durasiPerAudio * audioUrls.length);
            estimatedEndTime =
                '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
          }

          return {
            'key': key,
            'rawKey': entry.key,
            'title':
                combinedTitles.isNotEmpty
                    ? combinedTitles
                    : (source == 'otomatis'
                        ? '[Otomatis] ${schedule['category'] ?? schedule['title'] ?? 'Tanpa Judul'}'
                        : schedule['title'] ?? 'Tanpa Judul'),
            'category': schedule['category'] ?? schedule['title'] ?? '-',
            'hari': hari,
            'waktu': waktuStr,
            'endTime': schedule['endTime'] ?? estimatedEndTime ?? '-',
            'enabled': schedule['enabled'] ?? false,
            'source': source,
            'audioUrls': audioUrls,
          };
        } catch (e) {
          print("⚠ Error parsing entry ${entry.key} di $source: $e");
          return {
            'key': '$source-${entry.key}',
            'rawKey': entry.key,
            'title': 'Format Tidak Valid',
            'category': '-',
            'hari': '-',
            'waktu': '-',
            'endTime': '-',
            'enabled': false,
            'source': source,
            'audioUrls': [],
          };
        }
      }).toList();
    }

    loadedSchedules.addAll(parseSnapshot(manualSnapshot, 'manual'));
    loadedSchedules.addAll(parseSnapshot(otomatisSnapshot, 'otomatis'));

    setState(() {
      schedules = loadedSchedules;
      isLoading = false;
    });
  }

  void _checkAndTriggerAlarm(BuildContext context) async {
    final now = DateTime.now();

    for (var schedule in schedules) {
      final waktuStr = schedule['waktu'];
      final endTimeStr = schedule['endTime'];
      if (waktuStr == null || waktuStr == '-') continue;

      final timeParts = waktuStr.split(":");
      if (timeParts.length != 2) continue;

      final alarmTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.tryParse(timeParts[0]) ?? 0,
        int.tryParse(timeParts[1]) ?? 0,
      );

      if (schedule['enabled'] == true &&
          now.hour == alarmTime.hour &&
          now.minute == alarmTime.minute &&
          now.second == 0 &&
          currentlyPlayingKey != schedule['key']) {
        // Ambil semua audio
        final audioUrls = List<String>.from(schedule['audioUrls'] ?? []);
        if (audioUrls.isEmpty) return;

        final endTime = _parseTimeToDateTime(endTimeStr);
        if (endTime == null) return;

        currentAudioIndex = 0;
        currentAudioList = audioUrls;
        currentEndTime = endTime;
        currentlyPlayingKey = schedule['key'];

        _playNextAudioWithTimeCheck(schedule['title']);

        // Tambahkan AlarmPlayScreen
        if (context.mounted) {
          final alarmSchedule = AlarmSchedule(
            id: schedule['key'],
            title: schedule['title'],
            audioUrl: audioUrls.first,
            time: alarmTime,
            isActive: true,
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => AlarmPlayScreen(
                    alarm: alarmSchedule,
                    onResume: () async {
                      await musicPlayerService.resumeMusic();
                      if (context.mounted) Navigator.pop(context);
                    },
                    onStop: () async {
                      await musicPlayerService.stopMusic();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.daftar,
                          (route) => false,
                        );
                      }
                    },
                    musicPlayerService: musicPlayerService,
                    audioUrls: audioUrls, // untuk mode playlist
                  ),
            ),
          );
        }
      }
    }

    // Hentikan jika sudah lewat waktu
    if (currentEndTime != null &&
        DateTime.now().isAfter(currentEndTime!) &&
        currentlyPlayingKey != null) {
      await _audioPlayer.stop();
      currentlyPlayingKey = null;
      currentAudioList = [];
      currentAudioIndex = 0;
      currentEndTime = null;
      _showMiniStatusBar("🛌 Pemutaran selesai karena waktu habis");
    }
  }

  // Tambahkan fungsi bantu di dalam _DaftarJadwalScreenState
  DateTime? _parseTimeToDateTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    final parts = timeStr.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  void _playNextAudioWithTimeCheck(String title) async {
    if (currentAudioIndex >= currentAudioList.length ||
        DateTime.now().isAfter(currentEndTime!)) {
      await _audioPlayer.stop();
      setState(() {
        currentlyPlayingKey = null;
        currentAudioList = [];
        currentAudioIndex = 0;
        currentEndTime = null;
      });
      _showMiniStatusBar("🛌 Pemutaran selesai");
      return;
    }

    final audioUrl = currentAudioList[currentAudioIndex];
    try {
      await _audioPlayer.play(UrlSource(audioUrl));
      _showMiniStatusBar("▶ Memutar $title (${currentAudioIndex + 1})");

      _audioPlayer.onPlayerComplete.listen((event) {
        currentAudioIndex++;
        _playNextAudioWithTimeCheck(title);
      });
    } catch (e) {
      print("❌ Gagal memutar audio ke-$currentAudioIndex: $e");
      currentAudioIndex++;
      _playNextAudioWithTimeCheck(title);
    }
  }

  DatabaseReference _getRefBySource(String source) {
    switch (source) {
      case 'manual':
        return _manualRef;
      case 'otomatis':
        return _otomatisRef;
      default:
        throw Exception('Unknown source: $source');
    }
  }

  Future<void> _toggleSchedule(String key, bool isActive) async {
    try {
      final idx = schedules.indexWhere((s) => s['key'] == key);
      if (idx == -1) return;

      final schedule = schedules[idx];
      final ref = _getRefBySource(schedule['source']);

      setState(() {
        schedules[idx]['enabled'] = isActive;
      });

      await ref.child(schedule['rawKey']).update({"enabled": isActive});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Jadwal berhasil ${isActive ? 'diaktifkan' : 'dinonaktifkan'}',
          ),
        ),
      );
    } catch (e) {
      print("⚠ Gagal update jadwal $key: $e");
      setState(() {
        final idx = schedules.indexWhere((s) => s['key'] == key);
        if (idx != -1) schedules[idx]['enabled'] = !isActive;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mengubah status jadwal")),
      );
    }
  }

  Future<void> _deleteSchedule(String key) async {
    try {
      final idx = schedules.indexWhere((s) => s['key'] == key);
      if (idx == -1) return;

      final schedule = schedules[idx];
      final ref = _getRefBySource(schedule['source']);

      await ref.child(schedule['rawKey']).remove();

      setState(() {
        schedules.removeAt(idx);
        if (currentlyPlayingKey == key) currentlyPlayingKey = null;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Jadwal berhasil dihapus")));
    } catch (e) {
      print("⚠ Gagal hapus jadwal $key: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal menghapus jadwal")));
    }
  }

  void _editSchedule(Map<String, dynamic> schedule) {
    showDialog(
      context: context,
      builder: (context) {
        String newHari = schedule['hari'];
        String newStartTime = schedule['startTime'] ?? schedule['waktu'] ?? '';
        String newEndTime = schedule['endTime'] ?? '';

        return AlertDialog(
          title: const Text('Edit Jadwal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: newHari,
                decoration: const InputDecoration(
                  labelText: 'Hari (pisah koma jika banyak)',
                ),
                onChanged: (val) => newHari = val,
              ),
              TextFormField(
                initialValue: newStartTime,
                decoration: const InputDecoration(
                  labelText: 'Waktu Mulai (misal: 07:30)',
                ),
                onChanged: (val) => newStartTime = val,
              ),
              TextFormField(
                initialValue: newEndTime,
                decoration: const InputDecoration(
                  labelText: 'Waktu Selesai (misal: 08:00)',
                ),
                onChanged: (val) => newEndTime = val,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final ref = _getRefBySource(schedule['source']);
                  final hariList =
                      newHari.split(',').map((e) => e.trim()).toList();

                  await ref.child(schedule['rawKey']).update({
                    'hari': hariList,
                    'startTime': newStartTime,
                    'endTime': newEndTime,
                    'waktu': newStartTime,
                  });

                  final idx = schedules.indexWhere(
                    (s) => s['key'] == schedule['key'],
                  );
                  if (idx != -1) {
                    setState(() {
                      schedules[idx]['hari'] = newHari;
                      schedules[idx]['startTime'] = newStartTime;
                      schedules[idx]['endTime'] = newEndTime;
                      schedules[idx]['waktu'] = newStartTime; // fallback
                    });
                  }

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Jadwal berhasil diperbarui")),
                  );
                } catch (e) {
                  print("⚠ Gagal update jadwal ${schedule['key']}: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Gagal memperbarui jadwal")),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _togglePlayPause(String key, String audioUrl) async {
    if (currentlyPlayingKey == key) {
      await _audioPlayer.pause();
      setState(() {
        currentlyPlayingKey = null;
      });
      _showMiniStatusBar("⏸ Musik dijeda");
    } else {
      if (audioUrl.isEmpty) {
        _showMiniStatusBar("⚠ Audio URL kosong");
        return;
      }

      try {
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(audioUrl));
        setState(() {
          currentlyPlayingKey = key;
        });
        _showMiniStatusBar("▶ Memutar musik");
      } catch (e) {
        print("⚠ Error play audio $key: $e");
        _showMiniStatusBar("❌ Gagal memutar audio");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Daftar Jadwal",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background gradasi
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFA4D6FF), Color(0xFFE3F2FD)],
              ),
            ),
          ),

          // Bintang-bintang
          ..._buildStars(context),

          Container(
            padding: const EdgeInsets.only(top: 0),
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : schedules.isEmpty
                    ? const Center(child: Text("Belum ada jadwal"))
                    : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: schedules.length,
                      itemBuilder: (context, index) {
                        final schedule = schedules[index];
                        final isPlaying =
                            currentlyPlayingKey == schedule['key'];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            height: 200,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFFFE0E0), // Merah muda pastel
                                  Color(0xFFFFF4C2), // Kuning pastel
                                  Color(0xFFCCF2F4), // Biru pastel
                                  Color(0xFFE0BBE4), // Ungu pastel
                                ],
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (schedule['category'] != null &&
                                                schedule['category']
                                                    .toString()
                                                    .trim()
                                                    .isNotEmpty &&
                                                schedule['category']
                                                        .toString()
                                                        .trim() !=
                                                    '-')
                                            ? "${schedule['title']} (${schedule['category']})"
                                            : schedule['title'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        maxLines: null,
                                        overflow: TextOverflow.visible,
                                      ),

                                      const SizedBox(height: 4),
                                      ...[
                                            "Hari: ${schedule['hari']}",
                                            "Mulai: ${schedule['startTime'] ?? schedule['waktu']}",
                                            "Selesai: ${schedule['endTime'] != null && schedule['endTime'].toString().isNotEmpty ? schedule['endTime'] : '-'}",
                                            "Sumber: ${schedule['source'].toString().capitalize()}",
                                          ]
                                          .map(
                                            (text) => Text(
                                              text,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 120,
                                  child:
                                      schedule['source'] == 'otomatis'
                                          ? Column(
                                            // untuk otomatis, panjangkan ke bawah
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Switch.adaptive(
                                                value: schedule['enabled'],
                                                onChanged: (bool value) {
                                                  _toggleSchedule(
                                                    schedule['key'],
                                                    value,
                                                  );
                                                },
                                                activeColor: Colors.white,
                                                activeTrackColor:
                                                    Colors.blue[200],
                                                inactiveThumbColor: Colors.grey,
                                                inactiveTrackColor:
                                                    Colors.grey[400],
                                              ),
                                              const SizedBox(height: 4),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: Colors.blue,
                                                ),
                                                tooltip: "Edit Jadwal",
                                                onPressed:
                                                    () =>
                                                        _editSchedule(schedule),
                                              ),
                                              const SizedBox(height: 4),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.alarm,
                                                  color: Colors.orange,
                                                ),
                                                tooltip: "Buka Alarm",
                                                onPressed: () {
                                                  final audioUrl =
                                                      schedule['audioUrl'] ??
                                                      '';
                                                  final title =
                                                      schedule['title'] ??
                                                      'Alarm';

                                                  if (audioUrl.isEmpty) {
                                                    _showMiniStatusBar(
                                                      "⚠ Audio tidak tersedia",
                                                    );
                                                    return;
                                                  }
                                                  for (var schedule
                                                      in schedules) {
                                                    final List<String>
                                                    audioList = List<
                                                      String
                                                    >.from(
                                                      schedule['audioUrls'] ??
                                                          [],
                                                    );
                                                    final String? singleAudio =
                                                        schedule['audioUrl'];
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (
                                                              context,
                                                            ) => AlarmPlayScreen(
                                                              alarm: AlarmSchedule(
                                                                id:
                                                                    schedule['key'],
                                                                title:
                                                                    schedule['title'],
                                                                audioUrl:
                                                                    singleAudio ??
                                                                    "",
                                                                time:
                                                                    DateTime.now(),
                                                                isActive:
                                                                    schedule['enabled'] ??
                                                                    true,
                                                              ),
                                                              musicPlayerService:
                                                                  musicPlayerService,
                                                              // Cek: jika ada playlist, pakai audioUrls. Kalau tidak, pakai audioUrl
                                                              audioUrl:
                                                                  audioList
                                                                          .isEmpty
                                                                      ? singleAudio
                                                                      : null,
                                                              audioUrls:
                                                                  audioList
                                                                          .isNotEmpty
                                                                      ? audioList
                                                                      : null,
                                                              onResume: () async {
                                                                await musicPlayerService
                                                                    .resumeMusic();
                                                                Navigator.pop(
                                                                  context,
                                                                );
                                                              },
                                                              onStop: () async {
                                                                await musicPlayerService
                                                                    .stopMusic();
                                                                Navigator.pop(
                                                                  context,
                                                                );
                                                              },
                                                            ),
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
                                          )
                                          : Column(
                                            // untuk manual (tetap seperti semula)
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Switch.adaptive(
                                                value: schedule['enabled'],
                                                onChanged: (bool value) {
                                                  _toggleSchedule(
                                                    schedule['key'],
                                                    value,
                                                  );
                                                },
                                                activeColor: Colors.white,
                                                activeTrackColor:
                                                    Colors.blue[200],
                                                inactiveThumbColor: Colors.grey,
                                                inactiveTrackColor:
                                                    Colors.grey[400],
                                              ),
                                              const SizedBox(height: 10),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.edit,
                                                      color: Colors.blue,
                                                    ),
                                                    tooltip: "Edit Jadwal",
                                                    onPressed:
                                                        () => _editSchedule(
                                                          schedule,
                                                        ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                    ),
                                                    tooltip: "Hapus Jadwal",
                                                    onPressed:
                                                        () => _deleteSchedule(
                                                          schedule['key'],
                                                        ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.alarm,
                                                      color: Colors.orange,
                                                    ),
                                                    tooltip: "Buka Alarm",
                                                    onPressed: () {
                                                      final audioUrl =
                                                          schedule['audioUrl'] ??
                                                          '';
                                                      final title =
                                                          schedule['title'] ??
                                                          'Alarm';

                                                      if (audioUrl.isEmpty) {
                                                        _showMiniStatusBar(
                                                          "⚠ Audio tidak tersedia",
                                                        );
                                                        return;
                                                      }

                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder:
                                                              (
                                                                _,
                                                              ) => AlarmPlayScreen(
                                                                alarm: AlarmSchedule(
                                                                  id:
                                                                      schedule['key'],
                                                                  title:
                                                                      schedule['title'],
                                                                  audioUrl:
                                                                      schedule['audioUrl'],
                                                                  time:
                                                                      DateTime.now(),
                                                                  isActive:
                                                                      schedule['enabled'] ??
                                                                      true,
                                                                ),
                                                                musicPlayerService:
                                                                    musicPlayerService,
                                                                audioUrls: List<
                                                                  String
                                                                >.from(
                                                                  schedule['audioUrls'] ??
                                                                      [],
                                                                ),
                                                                onResume: () async {
                                                                  await musicPlayerService
                                                                      .resumeMusic();
                                                                  Navigator.pop(
                                                                    context,
                                                                  );
                                                                },
                                                                onStop: () async {
                                                                  await musicPlayerService
                                                                      .stopMusic();
                                                                  Navigator.pop(
                                                                    context,
                                                                  );
                                                                },
                                                              ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
