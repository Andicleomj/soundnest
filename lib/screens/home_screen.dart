import 'package:flutter/material.dart';
import 'package:soundnest/widgets/custom_navbar.dart';
import 'package:soundnest/widgets/menu_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 40), // Spasi atas
          
          // Logo
          Center(
            child: Image.asset(
              'assets/Logo 1.png',
              width: 120,
              height: 120,
            ),
          ),

          const SizedBox(height: 20),

          // Grid Menu
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              crossAxisCount: 3,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: [
                MenuItem(icon: 'assets/bell.png', label: "Bel"),
                MenuItem(icon: 'assets/musik.png', label: "Musik"),
                MenuItem(icon: 'assets/murottal.png', label: "Murottal\nAl-qur'an"),
                MenuItem(icon: 'assets/pemberitahuan.png', label: "Pemberitahuan"),
                MenuItem(icon: 'assets/volume.png', label: "Volume"),
              ],
            ),
          ),

          // Custom Bottom Navigation Bar
          CustomNavBar(),
        ],
      ),
    );
  }
}
