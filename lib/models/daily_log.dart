class DailyLog {
  final int? id;
  final int habitId;
  final String logDate; // ISO format: 2026-02-02
  final bool completed;
  final String? notes;

  DailyLog({
    this.id,
    required this.habitId,
    required this.logDate,
    this.completed = false,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'log_date': logDate,
      'completed': completed ? 1 : 0,
      'notes': notes,
    };
  }

  factory DailyLog.fromMap(Map<String, dynamic> map) {
    return DailyLog(
      id: map['id'] as int?,
      habitId: map['habit_id'] as int,
      logDate: map['log_date'] as String,
      completed: (map['completed'] as int) == 1,
      notes: map['notes'] as String?,
    );
  }

  DailyLog copyWith({bool? completed, String? notes}) {
    return DailyLog(
      id: id,
      habitId: habitId,
      logDate: logDate,
      completed: completed ?? this.completed,
      notes: notes ?? this.notes,
    );
  }
}
