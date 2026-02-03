import 'dart:async';
import 'package:flutter/material.dart';

class PhoneDownDialog extends StatefulWidget {
  const PhoneDownDialog({super.key});

  /// Show the dialog when all habits are completed
  static Future<void> showIfAllComplete({
    required BuildContext context,
    required int completedCount,
    required int totalCount,
  }) async {
    if (completedCount < totalCount) return;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const PhoneDownDialog(),
    );
  }

  @override
  State<PhoneDownDialog> createState() => _PhoneDownDialogState();
}

class _PhoneDownDialogState extends State<PhoneDownDialog> {
  int _secondsRemaining = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsRemaining--;
      });
      if (_secondsRemaining <= 0) {
        timer.cancel();
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.indigo.shade900,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🌙',
            style: TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          const Text(
            'All done!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Time to put the phone away.\nSweet dreams.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Closing in $_secondsRemaining...',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white38,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Good night',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }
}
