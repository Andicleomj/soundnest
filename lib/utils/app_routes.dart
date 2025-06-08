import 'package:flutter/material.dart';
import 'package:soundnest/screens/auth/forget_password_screen.dart';
import 'package:soundnest/screens/home/home_screen.dart';
import 'package:soundnest/screens/auth/login_screen.dart';
import 'package:soundnest/screens/auth/signup_screen.dart';
import 'package:soundnest/screens/schedule/schedule.dart';
import 'package:soundnest/screens/home/dashboard_screen.dart';
import 'package:soundnest/screens/schedule/buat_jadwal.dart';
import 'package:soundnest/screens/splash_screen.dart';
import 'package:soundnest/screens/home/musik/daftar_musik.dart';
import 'package:soundnest/screens/schedule/daftar.dart';
import 'package:soundnest/screens/schedule/murotal.dart';
import 'package:soundnest/screens/schedule/musik.dart';
import 'package:soundnest/screens/home/cast/cast_screen.dart';


class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/home';
  static const String login = '/login';
  static const String forgetPassword = '/forget-password';
  static const String signup = '/signup';
  static const String schedulescreen = '/schedule-screen';
  static const String dashboard = '/dashboard';
  static const String schedule = '/schedule';
  static const String cast = '/cast';
  static const String daftar = '/jadwal';
  static const String daftarMusik = '/daftar';
  static const String musik = '/jadwal-musik';
  static const String murotal = '/jadwal-murottal';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      home: (context) => const HomeScreen(),
      login: (context) => const LoginScreen(),
      forgetPassword: (context) => const ForgetPasswordScreen(),
      signup: (context) => const SignUpScreen(),
      schedulescreen: (context) => const ScheduleScreen(),
      dashboard: (context) => const DashboardScreen(),
      schedule: (context) => const Schedule(),
      cast: (context) => const CastScreen(playFromFileId: '',),
      daftar: (context) => const DaftarJadwalScreen(),
      musik: (context) => const MusikScheduleForm(),
      murotal: (context) => const MurottalScheduleForm(),

      daftarMusik: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map?;
        final String categoryId = args?['categoryId'] ?? '';
        final String categoryName = args?['categoryName'] ?? '';

        return DaftarMusikScreen(
          categoryId: categoryId,
          categoryName: categoryName,
        );
      },
    };
  }
}
