import 'package:flutter/material.dart';
import 'package:soundnest/service/cast_service.dart';
import 'package:cast/cast.dart';

class CastScreen extends StatefulWidget {
  final String streamingUrl;

  const CastScreen({Key? key, required this.streamingUrl}) : super(key: key);

  @override
  State<CastScreen> createState() => _CastScreenState();
}

class _CastScreenState extends State<CastScreen> {
  final CastService _castService = CastService();

  CastDevice? _selectedDevice;

  bool _isPlaying = false;
  bool _isConnecting = false;
  bool _isLoadingDevices = false;

  @override
  void initState() {
    super.initState();
    _searchDevices();
  }

  Future<void> _searchDevices() async {
    setState(() {
      _isLoadingDevices = true;
    });

    try {
      await _castService.discoverDevices(); // pakai discoverDevices()
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
      await _castService.playMedia(
        widget.streamingUrl,
        title: "Audio dari Google Drive",
      );
      setState(() {
        _selectedDevice = device;
        _isPlaying = true;
      });
    } catch (e) {
      debugPrint('Gagal connect/play: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memutar ke perangkat ${device.name ?? ''}')),
      );
    } finally {
      setState(() => _isConnecting = false);
    }
  }

  Future<void> _pause() async {
    await _castService.pause();
    setState(() => _isPlaying = false);
  }

  Future<void> _resume() async {
    await _castService.resume();
    setState(() => _isPlaying = true);
  }

  Future<void> _stop() async {
    await _castService.stop();
    setState(() {
      _isPlaying = false;
      _selectedDevice = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final devices = _castService.devices; // akses dari service

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cast Audio ke Google Nest'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoadingDevices ? null : _searchDevices,
            tooltip: 'Cari ulang perangkat',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoadingDevices
            ? const Center(child: CircularProgressIndicator())
            : devices.isEmpty
                ? const Center(child: Text('Tidak ada perangkat Chromecast ditemukan'))
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: devices.length,
                          itemBuilder: (context, index) {
                            final device = devices[index];
                            final isSelected = _selectedDevice == device;

                            return ListTile(
                              title: Text(device.name ?? "Perangkat Tidak Diketahui"),
                              subtitle: Text(device.host ?? ""),
                              trailing: ElevatedButton(
                                onPressed: (_isConnecting || (isSelected && _isPlaying))
                                    ? null
                                    : () => _connectAndPlay(device),
                                child: isSelected
                                    ? _isPlaying
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
                              onPressed: _isPlaying ? _pause : null,
                              tooltip: 'Pause',
                            ),
                            IconButton(
                              icon: const Icon(Icons.play_arrow),
                              onPressed: !_isPlaying ? _resume : null,
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
