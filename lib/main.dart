import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:soundnest/firebase_options.dart';
import 'package:soundnest/screens/home/volume/volume_control_service.dart';
import 'package:soundnest/screens/splash_screen.dart';
import 'package:soundnest/service/audio_controller.dart';
import 'package:soundnest/service/cast_service.dart';
import 'package:soundnest/service/music_player_service.dart';
import 'package:soundnest/service/schedule_service.dart';
import 'package:soundnest/screens/home/musik/musik_screen.dart';
import 'package:soundnest/screens/home/musik/daftar_musik.dart';
import 'package:soundnest/utils/app_routes.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:soundnest/screens/home/murottal/cast_screen.dart';

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
    final castService = CastService();
    final musicPlayerService = MusicPlayerService();
    final audioControllerService = AudioControllerService(
      castService,
      musicPlayerService,
    );

    runApp(
      MyApp(
        scheduleService: scheduleService,
        audioControllerService: audioControllerService,
      ),
    );
  } catch (e, stack) {
    print("❌ Gagal menginisialisasi Firebase: $e");
    print(stack);
  }
}

class MyApp extends StatelessWidget {
  final ScheduleService scheduleService;
  final AudioControllerService audioControllerService;

  const MyApp({
    super.key,
    required this.scheduleService,
    required this.audioControllerService,
  });

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
        '/music/list':
            (context) => DaftarMusikScreen(categoryId: '', categoryName: ''),
      },
      // ✅ Gunakan onGenerateRoute untuk parsing fileId dan kirim audioControllerService
      onGenerateRoute: (settings) {
        if (settings.name!.startsWith('/cast/')) {
          final fileId = settings.name!.split('/cast/').last;
          return MaterialPageRoute(
            builder:
                (context) => CastScreen(
                  streamingUrl: 'http://172.20.10.2:3000/stream/$fileId',
                  scheduleService: scheduleService,
                  audioControllerService: audioControllerService,
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
