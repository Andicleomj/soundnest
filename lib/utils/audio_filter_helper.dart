import 'package:flutter/services.dart';
import 'dart:developer' as dev;

class AudioFilterHelper {
  static const platform = MethodChannel('com.example.soundnest/audio');

  static Future<void> applyFilterForKids(bool enable, {double distance = 1.0}) async {
    try {
      dev.log("🎵 Memulai penerapan filter: enable=$enable, distance=$distance m", name: "AudioFilterHelper");
      await platform.invokeMethod('applyFilter', {
        'enable': enable,
        'distance': distance, // Pastikan distance dalam format yang sesuai di native
      });
      dev.log("🎵 Filter diterapkan berhasil: enable=$enable, distance=$distance m", name: "AudioFilterHelper");
    } on PlatformException catch (e) {
      dev.log("❌ Error applying filter (PlatformException): ${e.code} - ${e.message}", name: "AudioFilterHelper");
      throw Exception("Gagal menerapkan filter: ${e.message}");
    } catch (e) {
      dev.log("❌ Error applying filter (General): $e", name: "AudioFilterHelper");
      throw Exception("Gagal menerapkan filter: Terjadi kesalahan tak terduga");
    }
  }

  static Future<bool> isFilterActive() async {
    try {
      dev.log("📊 Memeriksa status filter", name: "AudioFilterHelper");
      final result = await platform.invokeMethod('isFilterActive') ?? false;
      dev.log("📊 Filter status: $result", name: "AudioFilterHelper");
      return result;
    } on PlatformException catch (e) {
      dev.log("❌ Error checking filter status (PlatformException): ${e.code} - ${e.message}", name: "AudioFilterHelper");
      return false;
    } catch (e) {
      dev.log("❌ Error checking filter status (General): $e", name: "AudioFilterHelper");
      return false;
    }
  }
}