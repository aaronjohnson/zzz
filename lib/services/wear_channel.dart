import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';

/// Handles communication between Flutter and native Wear OS code.
/// Only active on Android.
class WearChannel {
  static const _channel = MethodChannel('net.mqqn.quest.zzz/wear');
  static final DatabaseHelper _db = DatabaseHelper.instance;
  static bool _initialized = false;

  /// Initialize the channel and set up handlers for watch requests.
  static Future<void> initialize() async {
    if (_initialized || defaultTargetPlatform != TargetPlatform.android) return;

    _channel.setMethodCallHandler(_handleMethodCall);
    _initialized = true;

    // Send initial habits to watch
    await sendHabitsToWatch();
  }

  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'getHabits':
        return await _getHabitsJson();

      case 'toggleHabit':
        final habitId = call.arguments['habitId'] as int;
        final completed = call.arguments['completed'] as bool;
        await _toggleHabit(habitId, completed);
        // Send updated habits back to watch
        await sendHabitsToWatch();
        return null;

      default:
        throw PlatformException(
          code: 'NOT_IMPLEMENTED',
          message: 'Method ${call.method} not implemented',
        );
    }
  }

  static Future<String> _getHabitsJson() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final habits = await _db.getActiveHabits();
    final logs = await _db.getLogsForDate(today);

    final habitsList = habits.map((h) => {
      'id': h.id,
      'shortDesc': h.shortDesc,
      'completed': logs[h.id] ?? false,
    }).toList();

    return jsonEncode(habitsList);
  }

  static Future<void> _toggleHabit(int habitId, bool completed) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await _db.toggleHabitCompletion(habitId, today, completed);
  }

  /// Send current habits to watch. Call this whenever habits change.
  static Future<void> sendHabitsToWatch() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    try {
      final habitsJson = await _getHabitsJson();
      await _channel.invokeMethod('sendHabitsToWatch', {'habits': habitsJson});
    } catch (e) {
      // Watch may not be connected
      debugPrint('WearChannel: Failed to send habits to watch: $e');
    }
  }
}
