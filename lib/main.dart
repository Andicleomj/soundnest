import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:soundnest/firebase_options.dart';
import 'package:soundnest/service/schedule_service.dart'; // Import ScheduleService
import 'package:soundnest/screens/auth/signup_screen.dart'; // Import SignUpScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("🔧 Menginisialisasi Firebase...");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("✅ Firebase berhasil diinisialisasi.");

  // Inisialisasi ScheduleService
  final scheduleService = ScheduleService();
  scheduleService.start(); // Memulai pengecekan jadwal otomatis
  print("✅ ScheduleService berhasil dijalankan.");

  runApp(MyApp(scheduleService: scheduleService));
}

class MyApp extends StatelessWidget {
  final ScheduleService scheduleService;

  const MyApp({super.key, required this.scheduleService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoundNest',
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      routes: {
        '/home': (context) => HomePage(),
        '/signup': (context) => const SignUpScreen(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Firebase Test")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Firebase Initialized Successfully."),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              child: const Text("Go to Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
