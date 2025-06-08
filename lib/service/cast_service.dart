import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cast/cast.dart';
import 'dart:async';

typedef VoidCallback = void Function();

class CastService {
  static final CastService _instance = CastService._internal();
  factory CastService() => _instance;
  CastService._internal();

  CastSession? _session;
  CastDevice? _connectedDevice;

  bool isPlaying = false;
  String? currentFileId;

  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier(false);
  final ValueNotifier<String?> currentTitleNotifier = ValueNotifier(null);
  final ValueNotifier<String?> currentCategoryNotifier = ValueNotifier(null);
 final ValueNotifier<List<CastDevice>> devicesNotifier = ValueNotifier([]);
  VoidCallback? _onComplete;

  final List<CastDevice> _devices = [];
  List<CastDevice> get devices => _devices;

  StreamSubscription<CastSessionState>? _stateSubscription;
  StreamSubscription<dynamic>? _messageSubscription;

  String get _baseProxyUrl {
    if (kIsWeb) return 'http://localhost:3000';
    if (Platform.isAndroid) return 'http://192.168.0.102:3000';
    return 'http://localhost:3000';
  }

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

      _stateSubscription = session.stateStream.listen(
        _handleCastState,
        onError: (e) => debugPrint('⚠️ Error in state stream: $e'),
      );

      _messageSubscription = session.messageStream.listen((message) {
        debugPrint('💬 Received message: $message');
      });

      _session = session;
    } catch (e) {
      print('❌ Failed to connect: $e');
      _clearSession();
    }
  }

  void _handleCastState(CastSessionState state) {
    debugPrint('📶 Cast session state: $state');

    final stateStr = state.toString().toLowerCase();

    if (stateStr.contains('connected')) {
      final name = _connectedDevice?.name ?? 'Unknown';
      debugPrint('✅ Connected to device: $name');
    } else if (stateStr.contains('disconnected') || stateStr.contains('nosession') || stateStr.contains('no_session')) {
      debugPrint('🔌 Disconnected or no session detected');
      _clearSession();
    } else {
      debugPrint('ℹ️ Other session state: $state');
    }
  }

  Future<void> playFromFileId(String fileId, {String? title, String? category}) async {
    if (_session == null) throw Exception('Belum terhubung ke device');

    final proxyUrl = '$_baseProxyUrl/stream/$fileId';

    try {
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
            'contentId': proxyUrl,
            'streamType': 'BUFFERED',
            'contentType': 'audio/mpeg',
            'metadata': {
              'metadataType': 3,
              'title': title ?? 'Audio',
              'category': category ?? '',
            },
          },
          'autoplay': true,
        },
      );

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

    _session!.sendMessage(
      'urn:x-cast:com.google.cast.media',
      {
        'type': 'PAUSE',
        'mediaSessionId': 0,
      },
    );

    isPlaying = false;
    isPlayingNotifier.value = false;
    print('⏸️ Cast paused.');
  }

  Future<void> resume() async {
    if (_session == null || isPlaying) return;

    _session!.sendMessage(
      'urn:x-cast:com.google.cast.media',
      {
        'type': 'PLAY',
        'mediaSessionId': 0,
      },
    );

    isPlaying = true;
    isPlayingNotifier.value = true;
    print('▶️ Cast resumed.');
  }

  Future<void> stop() async {
    if (_session == null) return;

    _session!.sendMessage(
      'urn:x-cast:com.google.cast.media',
      {
        'type': 'STOP',
        'mediaSessionId': 0,
      },
    );

    _clearCurrentMedia();
    print('🛑 Cast stopped.');
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
}
