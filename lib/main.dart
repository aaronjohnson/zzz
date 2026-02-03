import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'screens/weekly_chart_screen.dart';
import 'services/notification_service.dart';
import 'services/wear_channel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database factory based on platform
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (defaultTargetPlatform == TargetPlatform.linux ||
             defaultTargetPlatform == TargetPlatform.windows ||
             defaultTargetPlatform == TargetPlatform.macOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // Android/iOS use native sqflite - no initialization needed

  // Initialize notifications (schedules daily bedtime reminder)
  await NotificationService.initialize();

  // Initialize watch communication on Android
  await WearChannel.initialize();

  runApp(const SleepHygieneApp());
}

class SleepHygieneApp extends StatelessWidget {
  const SleepHygieneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sleep Hygiene',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const WeeklyChartScreen(),
    );
  }
}
