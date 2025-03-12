import 'package:flutter/material.dart';
import 'config_loader.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Map<String, dynamic>? config;

  @override
  void initState() {
    super.initState();
    loadConfig();
  }

  Future<void> loadConfig() async {
    config = await ConfigLoader.loadConfig();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (config == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    var login = config!['loginScreen'];

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                login['logo'],
                width: login['width'].toDouble(),
                height: login['height'].toDouble(),
              ),
              SizedBox(height: 40),
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                    colors: [
                      Color(
                        int.parse(
                          login['buttonColorStart'].replaceFirst('#', '0xFF'),
                        ),
                      ),
                      Color(
                        int.parse(
                          login['buttonColorEnd'].replaceFirst('#', '0xFF'),
                        ),
                      ),
                    ],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    login['buttonText'],
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(
                        int.parse(login['textColor'].replaceFirst('#', '0xFF')),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  // Tambahkan navigasi ke halaman Sign Up jika ada
                },
                child: Text(
                  login['signUpText'],
                  style: TextStyle(
                    color: Color(
                      int.parse(login['signUpColor'].replaceFirst('#', '0xFF')),
                    ),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
