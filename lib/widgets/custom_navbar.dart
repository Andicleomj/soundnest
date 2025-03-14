import 'package:flutter/material.dart';
import 'package:soundnest/utils/app_routes.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tombol Home
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.home);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.home, color: Colors.white),
                const Text("Home", style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),

          // Tombol Penjadwalan
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.schedule);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule, color: Colors.white),
                const Text("Penjadwalan", style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),

          // Tombol Logout
          GestureDetector(
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
            },
            child: const Icon(Icons.logout, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }
}
