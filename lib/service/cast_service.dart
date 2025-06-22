import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cast/cast.dart';
import 'dart:async';

typedef VoidCallback = void Function();

class CastService {
  factory CastService() => _instance;

  CastService._internal();

  final ValueNotifier<String?> currentCategoryNotifier = ValueNotifier(null);
  String? currentFileId;
  final ValueNotifier<String?> currentTitleNotifier = ValueNotifier(null);
  final ValueNotifier<List<CastDevice>> devicesNotifier = ValueNotifier([]);
  bool isPlaying = false;
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier(false);

  static final CastService _instance = CastService._internal();

  CastDevice? _connectedDevice;
  final List<CastDevice> _devices = [];
  int? _mediaSessionId;
  StreamSubscription<dynamic>? _messageSubscription;
  VoidCallback? _onComplete;
  CastSession? _session;
  StreamSubscription<CastSessionState>? _stateSubscription;

  List<CastDevice> get devices => _devices;

  Future<void> discoverDevices() async {
    final foundDevices = await CastDiscoveryService().search();
    _devices
      ..clear()
      ..addAll(foundDevices);
    devicesNotifier.value = List.unmodifiable(_devices);
    print('📡 Devices found: ${_devices.map((d) => d.name).join(', ')}');
  }

  Future<void> connectToDevice(CastDevice device) async {
    try {
      _connectedDevice = device;
      final session = await CastSessionManager().startSession(device);

      await _stateSubscription?.cancel();
      await _messageSubscription?.cancel();

      final completer = Completer<void>();

      _stateSubscription = session.stateStream.listen((state) {
        _handleCastState(state);
        if (state == CastSessionState.connected) {
          completer.complete();
        }
      }, onError: (e) => debugPrint('⚠️ Error in state stream: $e'));

      _messageSubscription = session.messageStream.listen((message) {
        debugPrint('💬 Received message: $message');

        if (message is Map && message['mediaSessionId'] != null) {
          _mediaSessionId = message['mediaSessionId'];
          print('ℹ️ Media Session ID updated: $_mediaSessionId');
        }
      });

      _session = session;

      await completer.future.timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout waiting for cast session connection');
        },
      );
    } catch (e) {
      print('❌ Failed to connect: $e');
      _clearSession();
      rethrow;
    }
  }

  Future<void> playFromFileId(
    String fileId, {
    String? title,
    String? category,
  }) async {
    if (_session == null) throw Exception('Belum terhubung ke device');

    final proxyUrl = '$_baseProxyUrl/stream/$fileId';
    // Gunakan URL uji publik jika gagal
    final testUrl = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';

    try {
      print('📤 Sending LAUNCH...');
      _session!.sendMessage(CastSession.kNamespaceReceiver, {
        'type': 'LAUNCH',
        'appId': 'CC1AD845',
      });
      print('✅ LAUNCH sent.');

      await Future.delayed(const Duration(seconds: 5));

      print('📤 Sending LOAD...');
      _session!.sendMessage('urn:x-cast:com.google.cast.media', {
        'type': 'LOAD',
        'media': {
          'contentId': proxyUrl, // ganti dengan testUrl jika perlu
          'streamType': 'BUFFERED',
          'contentType': 'audio/mpeg',
          'metadata': {
            'metadataType': 0,
            'title': title ?? 'Audio',
          },
        },
        'autoplay': true,
      });
      print('✅ LOAD sent.');

      currentFileId = fileId;
      isPlaying = true;
      isPlayingNotifier.value = true;
      currentTitleNotifier.value = title;
      currentCategoryNotifier.value = category;

      print('🎶 Playing: $proxyUrl');
    } catch (e) {
      print('❌ Gagal casting musik: $e');
    }
  }

  Future<void> pause() async {
    if (_session == null || !isPlaying) return;

    _session!.sendMessage('urn:x-cast:com.google.cast.media', {
      'type': 'PAUSE',
      'mediaSessionId': _mediaSessionId,
    });

    isPlaying = false;
    isPlayingNotifier.value = false;
    print('⏸️ Cast paused.');
  }

  Future<void> resume() async {
    if (_session == null || isPlaying) return;

    _session!.sendMessage('urn:x-cast:com.google.cast.media', {
      'type': 'PLAY',
      'mediaSessionId': _mediaSessionId,
    });

    isPlaying = true;
    isPlayingNotifier.value = true;
    print('▶️ Cast resumed.');
  }

  Future<void> stop() async {
    if (_session == null) return;

    _session!.sendMessage('urn:x-cast:com.google.cast.media', {
      'type': 'STOP',
      'mediaSessionId': _mediaSessionId,
    });

    _clearCurrentMedia();
    print('🛑 Cast stopped.');
  }

  void setOnCompleteListener(VoidCallback callback) {
    _onComplete = callback;
  }

  Future<void> dispose() async {
    await stop();
    _clearSession();
    print('🗑️ Cast session disposed.');
  }

  String? get currentTitle => currentTitleNotifier.value;
  String? get currentCategory => currentCategoryNotifier.value;

  String get _baseProxyUrl {
    return 'https://28fa-118-96-203-155.ngrok-free.app';
  }

  void _handleCastState(CastSessionState state) {
    debugPrint('📶 Cast session state: $state');

    final stateStr = state.toString().toLowerCase();

    if (stateStr.contains('connected')) {
      final name = _connectedDevice?.name ?? 'Unknown';
      debugPrint('✅ Connected to device: $name');
    } else if (stateStr.contains('disconnected') ||
        stateStr.contains('nosession') ||
        stateStr.contains('no_session')) {
      debugPrint('🔌 Disconnected or no session detected');
      _clearSession();
    } else {
      debugPrint('ℹ️ Other session state: $state');
    }
  }

  void _clearCurrentMedia() {
    isPlaying = false;
    isPlayingNotifier.value = false;
    currentFileId = null;
    currentTitleNotifier.value = null;
    currentCategoryNotifier.value = null;
  }

  void _clearSession() {
    try {
      _stateSubscription?.cancel();
      _messageSubscription?.cancel();
    } catch (_) {}

    _session = null;
    _connectedDevice = null;
    _stateSubscription = null;
    _messageSubscription = null;

    _clearCurrentMedia();
    debugPrint('♻️ Session cleared safely.');
  }
}
