import 'package:flutter/material.dart';
import 'package:soundnest/screens/home_screen.dart';
import 'package:soundnest/screens/login_screen.dart';
import 'package:soundnest/screens/signup_screen.dart';
import 'package:soundnest/screens/schedule_screen.dart';
import 'package:soundnest/screens/dashboard_screen.dart';
import 'package:soundnest/screens/splash_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/home';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String schedule = '/schedule';
  static const String dashboard = '/dashboard';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      home: (context) => const HomeScreen(),
      login: (context) => const LoginScreen(),
      signup: (context) => const SignUpScreen(),
      schedule: (context) => const ScheduleScreen(),
      dashboard: (context) => const DashboardScreen(),
    };
  }
}
