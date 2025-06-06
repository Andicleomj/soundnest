import 'package:flutter/material.dart';
import 'package:soundnest/screens/home/bel/bel_screen.dart';
import 'package:soundnest/screens/home/pemberitahuan/notification_screen.dart';
import 'package:soundnest/screens/home/volume/volume_screen.dart';
import 'package:soundnest/widgets/custom_navbar.dart';
import 'package:soundnest/widgets/menu_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/bg home.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Foreground Content
          Column(
            children: [
              const SizedBox(height: 70),

              // Logo
              Center(
                child: Image.asset('assets/Logo 1.png', width: 200, height: 200),
              ),

              const SizedBox(height: 20),

              // Grid Menu
              Expanded(
                child: GridView.count(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  crossAxisCount: 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  children: [
                    MenuItem(
                      icon: 'assets/icons/bell.png',
                      label: "Bel",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BellScreen(),
                          ),
                        );
                      },
                    ),
                    MenuItem(
                      icon: 'assets/icons/musik.png',
                      label: "Musik",
                    ),
                    MenuItem(
                      icon: 'assets/icons/murottal.png',
                      label: "Murottal\nAl-qur'an",
                    ),
                    MenuItem(
                      icon: 'assets/icons/pemberitahuan.png',
                      label: "Pemberitahuan",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationScreen(),
                          ),
                        );
                      },
                    ),
                    MenuItem(
                      icon: 'assets/icons/volume.png',
                      label: "Volume",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VolumeScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Custom Bottom Navigation Bar
              CustomNavBar(),
            ],
          ),
        ],
      ),
    );
  }
}
