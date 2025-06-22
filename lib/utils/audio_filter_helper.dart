import 'package:flutter/services.dart';

class AudioFilterHelper {
  static const MethodChannel _channel = MethodChannel('com.example.soundnest/audio');

  static Future<void> applyFilterForKids(bool enable) async {
    try {
      await _channel.invokeMethod('applyFilter', {"enable": enable});
    } catch (e) {
      print('⚠️ Gagal mengaktifkan filter: $e');
    }
  }

  static Future<bool> isFilterActive() async {
    try {
      final result = await _channel.invokeMethod<bool>('isFilterActive');
      return result ?? false;
    } catch (e) {
      print('⚠️ Gagal memeriksa status filter: $e');
      return false;
    }
  }
}
