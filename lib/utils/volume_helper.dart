import 'package:shared_preferences/shared_preferences.dart';

class VolumeHelper {
  static const String _key = 'saved_volume';

  // Ambil volume 0.0 - 1.0
  static Future<double> getVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getDouble(_key) ?? 50) / 100;
  }

  // Simpan volume 0.0 - 1.0
  static Future<void> setVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key, volume * 100);
  }

  // Untuk tampilan UI
  static Future<int> getVolumePercentage() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getDouble(_key) ?? 50).toInt();
  }
}
