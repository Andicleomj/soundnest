import 'package:flutter/material.dart';
import 'package:soundnest/screens/auth/forget_password_screen.dart';
import 'package:soundnest/screens/auth/new_password_screen.dart';
import 'package:soundnest/screens/auth/reset_password_screen.dart';
import 'package:soundnest/screens/auth/verify_code_screen.dart';
import 'package:soundnest/screens/home/home_screen.dart';
import 'package:soundnest/screens/auth/login_screen.dart';
import 'package:soundnest/screens/auth/signup_screen.dart';
import 'package:soundnest/screens/scheduule/daftar%20jadwal/jadwal.dart';
import 'package:soundnest/screens/scheduule/daftar%20jadwal/list_schedule_screen.dart';
import 'package:soundnest/screens/scheduule/schedule.dart';
import 'package:soundnest/screens/scheduule/buat%20jadwal/schedule_screen.dart';
import 'package:soundnest/screens/home/dashboard_screen.dart';
import 'package:soundnest/screens/splash_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/home';
  static const String login = '/login';
  static const String forgetPassword = '/forget-password';
  static const String verifyCode = '/verify-code';
  static const String resetPassword = "/reset-password";
  static const String newPassword = "/new-password";
  static const String signup = '/signup';
  static const String schedulescreen = '/schedule-screen';
  static const String dashboard = '/dashboard';
  static const String listSchedule = "/list-schedule";
  static const String schedule = "/schedule";
  static const String daftarJadwal = "/jadwal";




  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      home: (context) => const HomeScreen(),
      login: (context) => const LoginScreen(),
      forgetPassword: (context) => const ForgetPasswordScreen(),
      verifyCode: (context) => const VerifyCodeScreen(),
      resetPassword: (context) => const ResetPasswordScreen(),
      newPassword: (context) => const NewPasswordScreen(),
      signup: (context) => const SignUpScreen(),
      schedulescreen: (context) => const ScheduleScreen(),
      dashboard: (context) => const DashboardScreen(),
      listSchedule: (context) => const ListScheduleScreen(),
      schedule: (context) => const Schedule(),
      daftarJadwal: (context) => const DaftarJadwal(),


    };
  }
}
