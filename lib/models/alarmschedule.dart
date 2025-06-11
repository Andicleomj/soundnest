class AlarmSchedule {
  final String id;
  final String title;
  final String audioUrl;
  final DateTime time;
  bool isActive;

  AlarmSchedule({
    required this.id,
    required this.title,
    required this.audioUrl,
    required this.time,
    this.isActive = true,
  });
}
