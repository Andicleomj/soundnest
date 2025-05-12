import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:soundnest/firebase_options.dart';
import 'package:soundnest/utils/app_routes.dart';
import 'package:soundnest/service/notifikasi_service.dart'; // Import NotifikasiService
import 'package:soundnest/service/schedule_service.dart'; // Import ScheduleService

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Inisialisasi Firebase
  // Inisialisasi Notifikasi
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Inisialisasi ScheduleService
  final scheduleService = ScheduleService();
  scheduleService.startScheduleChecker(); // Memulai pengecekan jadwal otomatis

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
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.getRoutes(),
    );
  }
}
