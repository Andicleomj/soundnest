import 'package:firebase_database/firebase_database.dart';

// update test : force commit

class ScheduleService {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref(
    'devices/device_001/schedules',
  );

  // Ambil semua jadwal
  Future<List<Map<String, dynamic>>> getSchedules() async {
    final snapshot = await _ref.get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return data.values.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      return [];
    }
  }

  // Tambahkan jadwal baru
  Future<void> addSchedule(Map<String, dynamic> scheduleData) async {
    await _ref.push().set(scheduleData);
  }
}
// tes