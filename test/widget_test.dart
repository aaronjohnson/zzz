import 'package:flutter_test/flutter_test.dart';

import 'package:zzz/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SleepHygieneApp());
    expect(find.text('Sleep Hygiene'), findsOneWidget);
  });
}
