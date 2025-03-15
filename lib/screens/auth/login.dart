import 'package:flutter/material.dart';
import 'package:soundnest/utils/app_routes.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username == "admin" && password == "admin123") {
      // Navigasi ke HomeScreen setelah login berhasil
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Username atau Password salah!"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/Logo 1.png',
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            const Text(
              "LOGIN",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            const Text("Username"),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            const Text("Password"),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  // Navigasi ke halaman Forgot Password
                  Navigator.pushNamed(context, AppRoutes.forgetPassword);
                },
                child: const Text(
                  "Forgot Password?",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: const BorderSide(color: Colors.blueAccent),
                  ),
                  elevation: 3,
                ),
                child: const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
