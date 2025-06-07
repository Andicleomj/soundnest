import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _reenterPasswordController = TextEditingController();

  bool _isButtonEnabled = false;
  bool _isPasswordVisible = false;
  bool _isReenterPasswordVisible = false;

  void _validateFields() {
    setState(() {
      _isButtonEnabled =
          _usernameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _reenterPasswordController.text.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_validateFields);
    _emailController.addListener(_validateFields);
    _passwordController.addListener(_validateFields);
    _reenterPasswordController.addListener(_validateFields);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _reenterPasswordController.dispose();
    super.dispose();
  }

  bool _isPasswordStrong(String password) {
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasMinLength = password.length >= 8;
    return hasUppercase && hasDigits && hasMinLength;
  }

  Future<void> _signUp() async {
    final password = _passwordController.text;
    final confirmPassword = _reenterPasswordController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password tidak cocok")),
      );
      return;
    }

    if (!_isPasswordStrong(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password harus minimal 8 karakter, mengandung huruf besar dan angka."),
        ),
      );
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: password.trim(),
      );

      await userCredential.user!.sendEmailVerification();

      final uid = userCredential.user!.uid;
      final DatabaseReference ref = FirebaseDatabase.instance.ref();
      await ref.child('users/$uid').set({
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
        'verified': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Akun berhasil dibuat! Silakan cek email untuk verifikasi."),
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = "Email sudah terdaftar.";
          break;
        case 'invalid-email':
          message = "Format email tidak valid.";
          break;
        case 'weak-password':
          message = "Password terlalu lemah.";
          break;
        default:
          message = "Gagal mendaftar: ${e.message}";
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mendaftar: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Image.asset(
                  'assets/Logo 1.png',
                  width: 200,
                  height: 200,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "SIGN UP",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              const Text("Nama Pengguna"),
              const SizedBox(height: 6),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  prefixIcon: Icon(Icons.person, size: 20),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
              const SizedBox(height: 16),

              const Text("Email"),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  prefixIcon: Icon(Icons.email, size: 20),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
              const SizedBox(height: 16),

              const Text("Kata Sandi"),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock, size: 20),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text("Ulangi Kata Sandi"),
              const SizedBox(height: 6),
              TextField(
                controller: _reenterPasswordController,
                obscureText: !_isReenterPasswordVisible,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isReenterPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isReenterPasswordVisible = !_isReenterPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  onPressed: _isButtonEnabled ? _signUp : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side: const BorderSide(color: Colors.blueAccent),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}