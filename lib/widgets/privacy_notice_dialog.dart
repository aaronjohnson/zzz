import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';

class PrivacyNoticeDialog extends StatelessWidget {
  const PrivacyNoticeDialog({super.key});

  static const _shownKey = 'privacy_notice_shown';

  static Future<void> showIfNeeded(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_shownKey) == true) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PrivacyNoticeDialog(),
    );

    await prefs.setBool(_shownKey, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEncrypted = DatabaseHelper.isEncrypted;

    return AlertDialog(
      icon: Icon(
        isEncrypted ? Icons.lock_outlined : Icons.shield_outlined,
        size: 48,
        color: isEncrypted ? Colors.green : null,
      ),
      title: Text(isEncrypted ? 'Your data stays with you' : 'Privacy Notice'),
      content: isEncrypted ? _buildMobileContent() : _buildDesktopContent(),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(isEncrypted ? 'Got it' : 'I understand'),
        ),
      ],
    );
  }

  Widget _buildMobileContent() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PrivacyBullet(
          icon: Icons.lock,
          text: 'Encrypted on your device',
        ),
        SizedBox(height: 12),
        _PrivacyBullet(
          icon: Icons.person_off,
          text: 'No account required',
        ),
        SizedBox(height: 12),
        _PrivacyBullet(
          icon: Icons.cloud_off,
          text: 'No data sent to servers',
        ),
        SizedBox(height: 12),
        _PrivacyBullet(
          icon: Icons.delete_forever,
          text: 'Uninstall = gone forever',
        ),
      ],
    );
  }

  Widget _buildDesktopContent() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your sleep data is stored locally but not encrypted on this platform.',
        ),
        SizedBox(height: 16),
        Text(
          'On mobile devices (Android/iOS), your data is protected with encryption at rest.',
          style: TextStyle(fontSize: 13),
        ),
        SizedBox(height: 16),
        Text(
          'Want desktop encryption? Let us know:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 4),
        SelectableText(
          'amj+features@mqqn.net',
          style: TextStyle(
            color: Colors.indigo,
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }
}

class _PrivacyBullet extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PrivacyBullet({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.green),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    );
  }
}
