import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soundnest/main.dart';
import 'package:soundnest/service/schedule_service.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Buat instance ScheduleService palsu (dummy)
    final scheduleService = ScheduleService();

    // Bangun aplikasi dengan ScheduleService dummy
    await tester.pumpWidget(MyApp(scheduleService: scheduleService));

    // Verifikasi aplikasi dapat berjalan
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
// test