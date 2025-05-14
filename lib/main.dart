import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:soundnest/firebase_options.dart';
import 'package:soundnest/service/schedule_service.dart';
import 'package:soundnest/screens/home/musik/musik_screen.dart'; // Import MusicScreen
import 'package:soundnest/screens/home/musik/musik_kategori.dart'; // Import MusikKategoriScreen
import 'package:soundnest/screens/home/musik/daftar_musik.dart'; // Import DaftarMusikScreen
import 'package:soundnest/utils/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("🔧 Menginisialisasi Firebase...");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("✅ Firebase berhasil diinisialisasi.");

  // Inisialisasi ScheduleService
  final scheduleService = ScheduleService();
  scheduleService.start();
  scheduleService.checkAndRunSchedule();
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
      initialRoute:
          FirebaseAuth.instance.currentUser == null
              ? AppRoutes.login
              : AppRoutes.home,
      routes: {
        ...AppRoutes.getRoutes(),
        '/music': (context) => const MusicScreen(),
        '/music/category':
            (context) => MusicCategoryScreen(), // Sesuaikan dengan nama baru
        '/music/list':
            (context) => DaftarMusikScreen(categoryId: '', categoryName: ''),
      },
    );
  }
}
