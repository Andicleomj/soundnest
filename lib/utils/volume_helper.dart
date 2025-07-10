import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as dev;

class VolumeHelper {
  static const String _key = 'saved_volume';
  static const double _defaultVolumePercentage = 50.0; // Default 50% sebagai persentase

  // Ambil volume 0.0 - 1.0
  static Future<double> getVolume() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPercentage = prefs.getDouble(_key) ?? _defaultVolumePercentage;
      final volume = (savedPercentage / 100).clamp(0.0, 1.0);
      dev.log("🎧 Volume diambil: $volume (persentase: $savedPercentage%)", name: "VolumeHelper");
      return volume;
    } catch (e) {
      dev.log("❌ Gagal mengambil volume: $e", name: "VolumeHelper");
      return _defaultVolumePercentage / 100; // Fallback ke 0.5
    }
  }

  // Simpan volume 0.0 - 1.0
  static Future<void> setVolume(double volume) async {
    try {
      if (volume < 0.0 || volume > 1.0) {
        throw ArgumentError("Volume harus antara 0.0 dan 1.0, diterima: $volume");
      }
      final prefs = await SharedPreferences.getInstance();
      final percentage = (volume * 100).toDouble();
      await prefs.setDouble(_key, percentage);
      dev.log("💾 Volume disimpan: $volume (persentase: $percentage%)", name: "VolumeHelper");
    } catch (e) {
      dev.log("❌ Gagal menyimpan volume: $e", name: "VolumeHelper");
      throw e; // Lempar error agar pemanggil bisa menanganinya
    }
  }

  // Untuk tampilan UI, kembalikan persentase 0-100
  static Future<int> getVolumePercentage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final percentage = (prefs.getDouble(_key) ?? _defaultVolumePercentage).clamp(0.0, 100.0).toInt();
      dev.log("📊 Persentase volume diambil: $percentage%", name: "VolumeHelper");
      return percentage;
    } catch (e) {
      dev.log("❌ Gagal mengambil persentase volume: $e", name: "VolumeHelper");
      return _defaultVolumePercentage.toInt(); // Fallback ke 50
    }
  }
}