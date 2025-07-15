import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController();

  // notifier agar tombol bisa mengubah warna & status enable/disable
  final ValueNotifier<bool> _emailValid = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _emailCtl.addListener(_validateEmailRealtime);
  }

  @override
  void dispose() {
    _emailCtl
      ..removeListener(_validateEmailRealtime)
      ..dispose();
    _emailValid.dispose();
    super.dispose();
  }

  /* ───────────────────── Helper ───────────────────── */

  // hanya @gmail.com & format umum
  bool _isValidEmail(String email) {
    final reg = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
    return reg.hasMatch(email) &&
        email.length >= 6 &&
        email.length <= 254;
  }

  void _validateEmailRealtime() {
    _emailValid.value = _isValidEmail(_emailCtl.text.trim());
  }

  /* ─────────────── Kirim link reset ─────────────── */

  Future<void> _sendResetPassword() async {
  final email = _emailCtl.text.trim();

  // validasi format lokal
  if (!_isValidEmail(email)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alamat e‑mail tidak valid')),
    );
    return;
  }

  try {
    // 🔍 1. Cek apakah e‑mail sudah terdaftar
    final methods =
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
    if (methods.isEmpty) {
      // e‑mail belum pernah sign‑up
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E‑mail belum terdaftar.')),
      );
      return; // hentikan di sini
    }

    // 🔑 2. Jika terdaftar → kirim link reset
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Link reset dikirim ke $email')),
    );
    Navigator.pop(context);

  } on FirebaseAuthException catch (e) {
    // kode error lain (jarang terjadi)
    String msg = 'Terjadi kesalahan (${e.code}).';
    if (e.code == 'invalid-email') msg = 'Format e‑mail tidak valid.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  } catch (e) {
    dev.log('Reset error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terjadi kesalahan, coba lagi.')),
    );
  }
}

  /* ───────────────────── UI ───────────────────── */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lupa Kata Sandi',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text(
                'Masukkan e‑mail Gmail Anda untuk menerima tautan reset.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              /* ─────────────── Input E‑mail ─────────────── */
              const Text('E‑mail'),
              const SizedBox(height: 5),
              TextFormField(
                controller: _emailCtl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'contoh@gmail.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (v) =>
                    v == null || !_isValidEmail(v) ? 'E‑mail Gmail tidak valid' : null,
              ),

              const SizedBox(height: 20),

              /* ─────────────── Tombol ─────────────── */
              ValueListenableBuilder<bool>(
                valueListenable: _emailValid,
                builder: (context, valid, _) => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: valid ? _sendResetPassword : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          valid ? Colors.blueAccent : Colors.grey.shade400,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Kirim Link Reset',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
