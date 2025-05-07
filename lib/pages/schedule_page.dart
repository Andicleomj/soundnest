import 'package:flutter/material.dart';
import '../service/schedule_service.dart';
import '../models/schedule_model.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final ScheduleService _scheduleService = ScheduleService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Jadwal Pemutaran")),
      body: FutureBuilder<List<Schedule>>(
        future: _scheduleService.getSchedules(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Terjadi kesalahan"));
          }

          final schedules = snapshot.data ?? [];

          if (schedules.isEmpty) {
            return const Center(child: Text("Belum ada jadwal"));
          }

          return ListView.builder(
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              final schedule = schedules[index];
              return ListTile(
                title: Text(schedule.musicName),
                subtitle: Text(
                  "${schedule.time} - ${schedule.days.join(', ')}",
                ),
                trailing: Icon(
                  schedule.active ? Icons.check_circle : Icons.cancel,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
