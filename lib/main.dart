import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:soundnest/firebase_options.dart';
import 'package:soundnest/screens/auth/auth_check.dart';
import 'package:soundnest/service/schedule_service.dart';
import 'package:soundnest/screens/home/musik/musik_screen.dart';
import 'package:soundnest/screens/home/musik/daftar_musik.dart';
import 'package:soundnest/utils/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print("🔧 Menginisialisasi Firebase...");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase berhasil diinisialisasi.");

    // Inisialisasi dan jalankan ScheduleService
    final scheduleService = ScheduleService();
    scheduleService.start();
    print("✅ ScheduleService berhasil dijalankan.");

    runApp(MyApp(scheduleService: scheduleService));
  } catch (e, stack) {
    print("❌ Gagal menginisialisasi Firebase: $e");
    print(stack);
  }
}

class MyApp extends StatelessWidget {
  final ScheduleService scheduleService;

  const MyApp({super.key, required this.scheduleService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoundNest',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthCheck(),
        ...AppRoutes.getRoutes(),
        '/music': (context) => const MusicScreen(),
        '/music/list':
            (context) => DaftarMusikScreen(categoryId: '', categoryName: ''),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
