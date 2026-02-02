import 'package:flutter/material.dart';
import 'screens/weekly_chart_screen.dart';

void main() {
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
