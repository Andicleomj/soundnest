import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:soundnest/firebase_options.dart';
import 'package:soundnest/screens/scheduule/schedule_screen.dart'; // Halaman Daftar Jadwal

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("🔧 Menginisialisasi Firebase...");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("✅ Firebase berhasil diinisialisasi.");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoundNest',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      routes: {'/schedule': (context) => const ScheduleScreen()},
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("SoundNest")),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          _buildIcon(context, Icons.music_note, "Musik"),
          _buildIcon(context, Icons.book, "Murottal Al-Qur'an"),
          _buildIcon(context, Icons.notifications, "Pemberitahuan"),
          _buildIcon(context, Icons.schedule, "Jadwal", route: '/schedule'),
        ],
      ),
    );
  }

  Widget _buildIcon(
    BuildContext context,
    IconData icon,
    String label, {
    String? route,
  }) {
    return GestureDetector(
      onTap: route != null ? () => Navigator.pushNamed(context, route) : () {},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50),
          const SizedBox(height: 10),
          Text(label),
        ],
      ),
    );
  }
}
