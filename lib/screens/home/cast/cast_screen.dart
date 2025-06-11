import 'package:flutter/material.dart';
import 'package:soundnest/service/cast_service.dart';
import 'package:cast/cast.dart';

class CastScreen extends StatefulWidget {
  final String playFromFileId;

  const CastScreen({Key? key, required this.playFromFileId}) : super(key: key);

  @override
  State<CastScreen> createState() => _CastScreenState();
}

class _CastScreenState extends State<CastScreen> {
  final CastService _castService = CastService();
  CastDevice? _selectedDevice;

  bool _isConnecting = false;
  bool _isLoadingDevices = false;

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

    _castService.devicesNotifier.addListener(_devicesListener);
    _castService.isPlayingNotifier.addListener(_playingListener);

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
      await _castService.playFromFileId(
        widget.playFromFileId,
        title: "Audio dari Google Drive",
      );
      setState(() {
        _selectedDevice = device;
      });
    } catch (e) {
      debugPrint('Gagal connect/play: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memutar ke ${device.name ?? ''}')),
      );
    } finally {
      setState(() => _isConnecting = false);
    }
  }

  Future<void> _pause() async => await _castService.pause();
  Future<void> _resume() async => await _castService.resume();
  Future<void> _stop() async {
    await _castService.stop();
    setState(() => _selectedDevice = null);
  }

  @override
  Widget build(BuildContext context) {
    final devices = _castService.devicesNotifier.value;
    final isPlaying = _castService.isPlayingNotifier.value;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Cast ke Google Nest',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoadingDevices ? null : _searchDevices,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:
            _isLoadingDevices
                ? const Center(child: CircularProgressIndicator())
                : devices.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cast, size: 60, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Tidak ada perangkat ditemukan',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _searchDevices,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
                : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          final device = devices[index];
                          final isSelected = _selectedDevice == device;
                          final isPlayingSelected = isSelected && isPlaying;

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            child: ListTile(
                              leading: const Icon(Icons.speaker),
                              title: Text(
                                device.name ?? 'Perangkat Tidak Diketahui',
                              ),
                              subtitle: Text(device.host ?? ''),
                              trailing: ElevatedButton(
                                onPressed:
                                    (_isConnecting || isPlayingSelected)
                                        ? null
                                        : () => _connectAndPlay(device),
                                child:
                                    isSelected
                                        ? isPlaying
                                            ? const Text('Sedang diputar')
                                            : const Text('Terhubung')
                                        : const Text('Cast'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isSelected ? Colors.green : Colors.blue,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (_selectedDevice != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.pause_circle_filled),
                              iconSize: 36,
                              tooltip: 'Pause',
                              onPressed: isPlaying ? _pause : null,
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(Icons.play_circle_fill),
                              iconSize: 36,
                              tooltip: 'Play',
                              onPressed: !isPlaying ? _resume : null,
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(Icons.stop_circle),
                              iconSize: 36,
                              tooltip: 'Stop',
                              onPressed: _stop,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
      ),
    );
  }
}
