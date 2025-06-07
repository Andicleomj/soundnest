import 'package:flutter_test/flutter_test.dart';
import 'package:soundnest/main.dart';
import 'package:soundnest/service/schedule_service.dart';
import 'package:soundnest/service/cast_service.dart';
import 'package:soundnest/service/music_player_service.dart';
import 'package:soundnest/service/audio_controller.dart';

void main() {
  testWidgets('Test MyApp dengan ScheduleService dan AudioControllerService', (
    WidgetTester tester,
  ) async {
    final scheduleService = ScheduleService();

    final castService = CastService();
    final musicPlayerService = MusicPlayerService();
    final audioControllerService = AudioControllerService(
      castService,
      musicPlayerService,
    );

    await tester.pumpWidget(
      MyApp(
        scheduleService: scheduleService,
        audioControllerService: audioControllerService,
      ),
    );

    expect(find.text('SoundNest'), findsOneWidget);
  });
}
