import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:soundnest/utils/app_routes.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  String? _usernameError;
  String? _passwordError;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _usernameError = null;
      _passwordError = null;
    });

    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    try {
      final DatabaseReference ref = FirebaseDatabase.instance.ref('users');
      final DataSnapshot snapshot = await ref.get();

      String? email;

      if (snapshot.exists) {
        final Map users = snapshot.value as Map;
        for (final entry in users.entries) {
          final user = Map<String, dynamic>.from(entry.value);
          if (user['username'] == username) {
            email = user['email'];
            break;
          }
        }
      }

      if (email == null) {
        setState(() {
          _usernameError = "Nama Pengguna tidak ditemukan";
        });
        return;
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login berhasil!")));
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        setState(() {
          _passwordError = "Kata sandi salah";
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login gagal: ${e.message}"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
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
                            const SizedBox(height: 30),
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

                      // Nama Pengguna
                      const Text("Nama Pengguna"),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          prefixIcon: const Icon(Icons.person, size: 20),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          errorText: _usernameError,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Kata Sandi
                      const Text("Kata Sandi"),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock, size: 20),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          errorText: _passwordError,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.forgetPassword,
                            );
                          },
                          child: const Text(
                            "Lupa Kata Sandi?",
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
                            "Login",
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                      ),
                      const Spacer(), // Tambahkan agar kolom bisa dorong ke atas saat keyboard muncul
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
