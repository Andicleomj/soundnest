import 'dart:convert';
import 'package:flutter/services.dart';

class ConfigLoader {
  static Future<Map<String, dynamic>> loadConfig() async {
    String data = await rootBundle.loadString('assets/config.json');
    return json.decode(data);
  }
}
