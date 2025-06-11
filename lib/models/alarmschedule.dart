class AlarmSchedule {
  final String id;
  final String title;
  final String audioUrl;
  final DateTime time;
  final List<String> days; // ⬅️ Tambahan ini
  bool isActive;

  AlarmSchedule({
    required this.id,
    required this.title,
    required this.audioUrl,
    required this.time,
    required this.days, // ⬅️ Tambahkan di constructor juga
    this.isActive = true,
  });
}

