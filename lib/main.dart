import 'package:flutter/material.dart';
import 'package:soundnest/utils/app_routes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
