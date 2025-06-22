import 'package:flutter/services.dart';

class NativeCastService {
  static const _channel = MethodChannel('com.example.soundnest/audio');

  static Future<void> play(String url, {String title = 'Audio'}) async {
    await _channel.invokeMethod('castPlay', {
      'url': url,
      'title': title,
    });
  }

  static Future<void> pause() async {
    await _channel.invokeMethod('castPause');
  }

  static Future<void> resume() async {
    await _channel.invokeMethod('castResume');
  }

  static Future<void> stop() async {
    await _channel.invokeMethod('castStop');
  }

  static Future<void> applyFilter(bool enable) async {
    await _channel.invokeMethod('applyFilter', {'enable': enable});
  }

  static Future<bool> isFilterActive() async {
    final result = await _channel.invokeMethod('isFilterActive');
    return result == true;
  }
}
