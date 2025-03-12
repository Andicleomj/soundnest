import 'package:flutter/material.dart';
import 'package:soundnest/login_screen.dart';
import 'config_loader.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Map<String, dynamic>? config;

  @override
  void initState() {
    super.initState();
    loadConfig();
  }

  Future<void> loadConfig() async {
    config = await ConfigLoader.loadConfig();
    Future.delayed(
      Duration(milliseconds: config!['splashScreen']['duration']),
      () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context)  => LoginScreen()),
        );
      },
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (config == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    var splash = config!['splashScreen'];
    return Scaffold(
      backgroundColor: Color(
        int.parse(splash['backgroundColor'].replaceFirst('#', '0xFF')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              splash['logo'],
              width: splash['width'].toDouble(),
              height: splash['height'].toDouble(),
            ),
            SizedBox(height: 20),
            Text(
              splash['text']['content'],
              style: TextStyle(
                fontSize: splash['text']['fontSize'].toDouble(),
                color: Color(
                  int.parse(splash['text']['color'].replaceFirst('#', '0xFF')),
                ),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
