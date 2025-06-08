import 'package:flutter/material.dart';
import 'package:soundnest/service/cast_service.dart';
import 'package:cast/cast.dart';
import 'package:soundnest/service/schedule_service.dart';

class CastScreen extends StatefulWidget {
  final String  playFromFileId; // Bisa diubah jadi fileId jika pakai playFromFileId

  const CastScreen({
    Key? key,
    required this. playFromFileId,
  }) : super(key: key);

  @override
  State<CastScreen> createState() => _CastScreenState();
}

class _CastScreenState extends State<CastScreen> {
  final CastService _castService = CastService();
  CastDevice? _selectedDevice;

  bool _isConnecting = false;
  bool _isLoadingDevices = false;

  // Simpan listener agar bisa di-remove dengan benar
  late VoidCallback _devicesListener;
  late VoidCallback _playingListener;

  @override
  void initState() {
    super.initState();

    _devicesListener = () {
      setState(() {});
    };
    _playingListener = () {
      setState(() {});
    };

    // Listen perubahan daftar perangkat cast
    _castService.devicesNotifier.addListener(_devicesListener);

    // Listen status playing supaya UI update otomatis
    _castService.isPlayingNotifier.addListener(_playingListener);

    // Optional: langsung cari perangkat saat init
    _searchDevices();
  }

  @override
  void dispose() {
    _castService.devicesNotifier.removeListener(_devicesListener);
    _castService.isPlayingNotifier.removeListener(_playingListener);
    super.dispose();
  }

  Future<void> _searchDevices() async {
    setState(() {
      _isLoadingDevices = true;
    });

    try {
      await _castService.discoverDevices();
    } catch (e) {
      debugPrint('Gagal mencari perangkat: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mencari perangkat Cast')),
      );
    } finally {
      setState(() {
        _isLoadingDevices = false;
      });
    }
  }

  Future<void> _connectAndPlay(CastDevice device) async {
    setState(() => _isConnecting = true);
    try {
      await _castService.connectToDevice(device);

      // Asumsi streamingUrl adalah fileId untuk demo ini
      await _castService.playFromFileId(
        widget. playFromFileId,
        title: "Audio dari Google Drive",
      );

      setState(() {
        _selectedDevice = device;
      });
    } catch (e) {
      debugPrint('Gagal connect/play: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memutar ke perangkat ${device.name ?? ''}'),
        ),
      );
    } finally {
      setState(() => _isConnecting = false);
    }
  }

  Future<void> _pause() async {
    await _castService.pause();
  }

  Future<void> _resume() async {
    await _castService.resume();
  }

  Future<void> _stop() async {
    await _castService.stop();
    setState(() {
      _selectedDevice = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final devices = _castService.devicesNotifier.value;
    final isPlaying = _castService.isPlayingNotifier.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cast Audio ke Google Nest'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoadingDevices ? null : _searchDevices,
            tooltip: 'Cari ulang perangkat',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoadingDevices
            ? const Center(child: CircularProgressIndicator())
            : devices.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Tidak ada perangkat Chromecast ditemukan',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                        onPressed: _searchDevices,
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: devices.length,
                          itemBuilder: (context, index) {
                            final device = devices[index];
                            final isSelected = _selectedDevice == device;

                            return ListTile(
                              title: Text(
                                device.name ?? "Perangkat Tidak Diketahui",
                              ),
                              subtitle: Text(device.host ?? ""),
                              trailing: ElevatedButton(
                                onPressed: (_isConnecting || (isSelected && isPlaying))
                                    ? null
                                    : () => _connectAndPlay(device),
                                child: isSelected
                                    ? isPlaying
                                        ? const Text('Sedang diputar')
                                        : const Text('Terhubung')
                                    : const Text('Cast'),
                              ),
                            );
                          },
                        ),
                      ),
                      if (_selectedDevice != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.pause),
                              onPressed: isPlaying ? _pause : null,
                              tooltip: 'Pause',
                            ),
                            IconButton(
                              icon: const Icon(Icons.play_arrow),
                              onPressed: !isPlaying ? _resume : null,
                              tooltip: 'Play',
                            ),
                            IconButton(
                              icon: const Icon(Icons.stop),
                              onPressed: _stop,
                              tooltip: 'Stop',
                            ),
                          ],
                        ),
                    ],
                  ),
      ),
    );
  }
}
