import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soundnest/main.dart';

void main() {
  testWidgets('Test MyApp tanpa ScheduleService dan NotificationService', (
    WidgetTester tester,
  ) async {
    // Bangun aplikasi tanpa ScheduleService dan NotificationService
    await tester.pumpWidget(const MyApp());

    // Verifikasi apakah widget muncul
    expect(find.text('Firebase Test'), findsOneWidget);

    // Verifikasi tombol navigasi ke SignUp ada
    expect(find.text('Go to Sign Up'), findsOneWidget);

    // Simulasi klik tombol untuk navigasi
    await tester.tap(find.text('Go to Sign Up'));
    await tester.pumpAndSettle();

    // Verifikasi apakah halaman SignUp muncul
    expect(find.text('Sign Up'), findsOneWidget);
  });
}
