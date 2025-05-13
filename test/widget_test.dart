import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:soundnest/main.dart';
import 'package:soundnest/service/schedule_service.dart';

// tes
void main() {
  testWidgets('Test MyApp dengan ScheduleService', (WidgetTester tester) async {
    // Inisialisasi ScheduleService untuk pengujian
    final scheduleService = ScheduleService();

    // Bangun aplikasi dengan ScheduleService
    await tester.pumpWidget(MyApp(scheduleService: scheduleService));

    // Verifikasi apakah widget muncul
    expect(find.text('SoundNest'), findsOneWidget);
  });
}
