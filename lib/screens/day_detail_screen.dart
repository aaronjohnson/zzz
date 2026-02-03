import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/habit.dart';
import '../services/wear_channel.dart';
import '../widgets/phone_down_dialog.dart';

class DayDetailScreen extends StatefulWidget {
  final String date;

  const DayDetailScreen({super.key, required this.date});

  @override
  State<DayDetailScreen> createState() => _DayDetailScreenState();
}

class _DayDetailScreenState extends State<DayDetailScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Habit> _habits = [];
  Map<int, bool> _dayLogs = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    final habits = await _db.getActiveHabits();
    final logs = await _db.getLogsForDate(widget.date);

    setState(() {
      _habits = habits;
      _dayLogs = logs;
      _loading = false;
    });
  }

  Future<void> _toggleHabit(int habitId, bool currentValue) async {
    await _db.toggleHabitCompletion(habitId, widget.date, !currentValue);
    setState(() {
      _dayLogs[habitId] = !currentValue;
    });
    // Sync to watch
    WearChannel.sendHabitsToWatch();

    // Check if all habits complete for today
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (widget.date == today && !currentValue) {
      final completedCount = _dayLogs.values.where((v) => v).length;
      PhoneDownDialog.showIfAllComplete(
        context: context,
        completedCount: completedCount,
        totalCount: _habits.length,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(widget.date);
    final dateText = DateFormat('EEEE, MMMM d').format(date);

    // Group habits by category
    final habitsByCategory = <String, List<Habit>>{};
    for (final habit in _habits) {
      habitsByCategory.putIfAbsent(habit.category, () => []);
      habitsByCategory[habit.category]!.add(habit);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(dateText),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: habitsByCategory.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        entry.key,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                    ...entry.value.map((habit) {
                      final completed = _dayLogs[habit.id] ?? false;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => _toggleHabit(habit.id!, completed),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Checkbox
                                Container(
                                  width: 28,
                                  height: 28,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    color: completed
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                    border: Border.all(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: completed
                                      ? Icon(
                                          Icons.check,
                                          size: 20,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        )
                                      : null,
                                ),
                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        habit.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              decoration: completed
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        habit.longDesc,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                  ],
                );
              }).toList(),
            ),
    );
  }
}
