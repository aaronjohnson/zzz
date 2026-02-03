import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/habit.dart';
import '../services/wear_channel.dart';
import '../widgets/phone_down_dialog.dart';
import '../widgets/privacy_notice_dialog.dart';
import 'day_detail_screen.dart';

class WeeklyChartScreen extends StatefulWidget {
  const WeeklyChartScreen({super.key});

  @override
  State<WeeklyChartScreen> createState() => _WeeklyChartScreenState();
}

class _WeeklyChartScreenState extends State<WeeklyChartScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Habit> _habits = [];
  Map<String, Map<int, bool>> _weekLogs = {};
  late DateTime _weekStart;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _weekStart = _getWeekStart(DateTime.now());
    _loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PrivacyNoticeDialog.showIfNeeded(context);
    });
  }

  DateTime _getWeekStart(DateTime date) {
    // Start week on Monday
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }

  List<String> _getWeekDates() {
    return List.generate(7, (i) {
      final date = _weekStart.add(Duration(days: i));
      return DateFormat('yyyy-MM-dd').format(date);
    });
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    final habits = await _db.getActiveHabits();
    final weekDates = _getWeekDates();
    final logs = await _db.getLogsForWeek(weekDates);

    setState(() {
      _habits = habits;
      _weekLogs = logs;
      _loading = false;
    });
  }

  void _previousWeek() {
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
    });
    _loadData();
  }

  void _nextWeek() {
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
    });
    _loadData();
  }

  Future<void> _toggleHabit(int habitId, String date, bool currentValue) async {
    await _db.toggleHabitCompletion(habitId, date, !currentValue);
    setState(() {
      _weekLogs[date] ??= {};
      _weekLogs[date]![habitId] = !currentValue;
    });
    // Sync to watch
    WearChannel.sendHabitsToWatch();

    // Check if all habits complete for today
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (date == today && !currentValue) {
      final todayLogs = _weekLogs[today] ?? {};
      final completedCount = todayLogs.values.where((v) => v).length;
      PhoneDownDialog.showIfAllComplete(
        context: context,
        completedCount: completedCount,
        totalCount: _habits.length,
      );
    }
  }

  void _openDayDetail(String date) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DayDetailScreen(date: date),
      ),
    ).then((_) => _loadData()); // Refresh on return
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = _getWeekDates();
    final weekEnd = _weekStart.add(const Duration(days: 6));
    final dateRangeText =
        '${DateFormat('MMM d').format(_weekStart)} - ${DateFormat('MMM d, y').format(weekEnd)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Hygiene'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Week navigation
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _previousWeek,
                      ),
                      Text(
                        dateRangeText,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _nextWeek,
                      ),
                    ],
                  ),
                ),

                // Day headers
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const SizedBox(width: 120), // Habit name column
                      ...weekDates.map((date) {
                        final dt = DateTime.parse(date);
                        final isToday = DateFormat('yyyy-MM-dd')
                                .format(DateTime.now()) ==
                            date;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => _openDayDetail(date),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: isToday
                                  ? BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                      borderRadius: BorderRadius.circular(4),
                                    )
                                  : null,
                              child: Text(
                                DateFormat('E').format(dt).substring(0, 1),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: isToday
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                const Divider(),

                // Habits grid
                Expanded(
                  child: ListView.builder(
                    itemCount: _habits.length,
                    itemBuilder: (context, index) {
                      final habit = _habits[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 120,
                              child: Text(
                                habit.shortDesc,
                                style: Theme.of(context).textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                            ...weekDates.map((date) {
                              final completed =
                                  _weekLogs[date]?[habit.id] ?? false;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      _toggleHabit(habit.id!, date, completed),
                                  child: Container(
                                    height: 32,
                                    margin: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: completed
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: completed
                                        ? Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                          )
                                        : null,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Footer hint
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Tap a day header for details',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ),
              ],
            ),
    );
  }
}
