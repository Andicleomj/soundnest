import 'package:cast/cast.dart';

class CastService {
  CastSession? _session;

  // Tambahan: menyimpan daftar perangkat yang ditemukan
  final List<CastDevice> _devices = [];

  // Getter: untuk akses dari luar
  List<CastDevice> get devices => _devices;

  /// Temukan perangkat cast, dan simpan ke _devices
  Future<void> discoverDevices() async {
    final foundDevices = await CastDiscoveryService().search();
    _devices
      ..clear()
      ..addAll(foundDevices);
  }

  /// Connect ke device
  Future<void> connectToDevice(CastDevice device) async {
    _session = await CastSessionManager().startSession(device);

    _session!.stateStream.listen((state) async {
      print('Cast session state: $state');

      if (state == CastSessionState.connected) {
        print('Connected to device: ${device.name}');
      }
    });

    _session!.messageStream.listen((message) {
      print('Received message: $message');
    });
  }

  /// Play audio ke device cast
  Future<void> playMedia(String url, {String? title}) async {
    if (_session == null) throw Exception('Belum terhubung ke device cast');

    try {
      // Launch default media receiver app (CC1AD845 = default receiver)
      _session!.sendMessage(
        CastSession.kNamespaceReceiver,
        {
          'type': 'LAUNCH',
          'appId': 'CC1AD845',
        },
      );

      await Future.delayed(const Duration(seconds: 2));

      _session!.sendMessage(
        'urn:x-cast:com.google.cast.media',
        {
          'type': 'LOAD',
          'media': {
            'contentId': url,
            'streamType': 'BUFFERED',
            'contentType': 'audio/mpeg',
            'metadata': {
              'metadataType': 3,
              'title': title ?? 'Audio',
            },
          },
          'autoplay': true,
        },
      );
    } catch (e) {
      print('sendMessage error: $e');
      rethrow;
    }
  }

  /// Pause
  Future<void> pause() async {
    if (_session == null) return;
    _session!.sendMessage('urn:x-cast:com.google.cast.media', {
      'type': 'PAUSE',
      'mediaSessionId': 0,
    });
  }

  /// Resume
  Future<void> resume() async {
    if (_session == null) return;
    _session!.sendMessage('urn:x-cast:com.google.cast.media', {
      'type': 'PLAY',
      'mediaSessionId': 0,
    });
  }

  /// Stop
  Future<void> stop() async {
    if (_session == null) return;
    _session!.sendMessage('urn:x-cast:com.google.cast.media', {
      'type': 'STOP',
      'mediaSessionId': 0,
    });
  }
}
