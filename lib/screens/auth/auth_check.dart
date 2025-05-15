import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soundnest/utils/app_routes.dart';

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Tampilkan loading dulu
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Cek apakah user sudah login
        if (snapshot.hasData) {
          print("✅ User sudah login: ${snapshot.data!.email}");
          Future.microtask(() =>
              Navigator.pushReplacementNamed(context, AppRoutes.home));
        } else {
          print("⚠️ User belum login.");
          Future.microtask(() =>
              Navigator.pushReplacementNamed(context, AppRoutes.login));
        }

        return const SizedBox(); // widget sementara sebelum redirect
      },
    );
  }
}
