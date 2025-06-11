import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:soundnest/firebase_options.dart';
import 'package:soundnest/screens/home/volume/volume_control_service.dart';
import 'package:soundnest/screens/splash_screen.dart';
import 'package:soundnest/service/schedule_service.dart';
import 'package:soundnest/screens/home/musik/musik_screen.dart';
import 'package:soundnest/screens/home/musik/daftar_musik.dart';
import 'package:soundnest/utils/app_routes.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:soundnest/screens/home/cast/cast_screen.dart'; 


Future<void> requestMicPermission() async {
  if (await Permission.microphone.request().isGranted) {
    print("🎤 Microphone permission granted");
  } else {
    print("⚠️ Microphone permission denied");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // inisialisasi volume control 
  await initVolumeControl();
  
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

    await requestMicPermission();

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
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        ...AppRoutes.getRoutes(),
        '/music': (context) => const MusicScreen(),
        '/music/list': (context) =>
            DaftarMusikScreen(categoryId: '', categoryName: ''),
      },
      // ✅ Gunakan onGenerateRoute untuk parsing fileId
      onGenerateRoute: (settings) {
        if (settings.name!.startsWith('/cast/')) {
          final fileId = settings.name!.split('/cast/').last;
          return MaterialPageRoute(
            builder: (context) => CastScreen(
              playFromFileId: 'http://192.168.0.102:3000/stream/$fileId',
            ),
          );
        }
        return null;
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}