import 'package:firebase_database/firebase_database.dart';
import 'package:soundnest/service/schedule_service.dart';
import 'package:flutter/material.dart';
import 'package:soundnest/utils/app_routes.dart';

final ScheduleService _scheduleService = ScheduleService();

// Ambil data
void _loadSchedules() async {
  final data = await _scheduleService.getSchedules();
  // setState atau tampilkan data
}

// force commit
// Tambah data
void _createSchedule() async {
  final newSchedule = {
    'type': 'musik',
    'day': 'monday',
    'time_start': '10:00',
    'time_end': '10:40',
    'url': 'https://example.com/audio.mp3',
  };
  await _scheduleService.addSchedule(newSchedule);
}
