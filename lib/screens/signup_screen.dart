import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _reenterPasswordController = TextEditingController();

  bool _isButtonEnabled = false;

  void _validateFields() {
    setState(() {
      _isButtonEnabled = _usernameController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _reenterPasswordController.text.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_validateFields);
    _passwordController.addListener(_validateFields);
    _reenterPasswordController.addListener(_validateFields);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _reenterPasswordController.dispose();
    super.dispose();
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
            // Logo di tengah
            Center(
              child: Image.asset(
                'assets/Logo 1.png', // Sesuaikan dengan nama file logo
                width: 120,
                height: 120,
              ),
            ),
            const SizedBox(height: 20),

            // Teks SIGN UP
            const Text(
              "SIGN UP",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            // Input Username
            const Text("Username"),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Input Password
            const Text("Password"),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Input Re-Enter Password
            const Text("Re-Enter Password"),
            TextField(
              controller: _reenterPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),

            // Tombol Sign Up
            Center(
              child: ElevatedButton(
                onPressed: _isButtonEnabled
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Akun berhasil dibuat!")),
                        );
                        Navigator.pop(context);
                      }
                    : null, // Disabled jika field kosong
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  backgroundColor: _isButtonEnabled ? Colors.blueAccent : Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 3,
                ),
                child: Text(
                  "Sign Up",
                  style: TextStyle(
                    fontSize: 16,
                    color: _isButtonEnabled ? Colors.white : Colors.black45,
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
