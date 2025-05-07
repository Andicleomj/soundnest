class Schedule {
  final String type;
  final String musicName;
  final String time;
  final List<String> days;
  final String url;
  final int volume;
  final String repeat;
  final bool active;

  Schedule({
    required this.type,
    required this.musicName,
    required this.time,
    required this.days,
    required this.url,
    required this.volume,
    required this.repeat,
    required this.active,
  });

  // Konversi dari Map (Firebase) ke Schedule
  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      type: map['type'] ?? '',
      musicName: map['music_name'] ?? '',
      time: map['time'] ?? '',
      days: List<String>.from(map['days'] ?? []),
      url: map['url'] ?? '',
      volume: map['volume'] ?? 100,
      repeat: map['repeat'] ?? '',
      active: map['active'] ?? false,
    );
  }

  // Konversi dari Schedule ke Map (untuk simpan ke Firebase)
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'music_name': musicName,
      'time': time,
      'days': days,
      'url': url,
      'volume': volume,
      'repeat': repeat,
      'active': active,
    };
  }
}
