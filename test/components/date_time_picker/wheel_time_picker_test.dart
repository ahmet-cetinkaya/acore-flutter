import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acore/components/date_time_picker/wheel_time_picker.dart';

void main() {
  testWidgets('WheelTimePicker handles scrolling past 24 hours correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WheelTimePicker(
            initialTime: const TimeOfDay(hour: 10, minute: 30),
            onTimeChanged: (time) {
              // Time change callback - just verify it doesn't crash
            },
          ),
        ),
      ),
    );

    // Initial state
    expect(find.text('10'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);

    // Scroll hour to index 24 (which should be hour 0)
    // The initial item is 10.
    // We want to scroll to 24.
    // The itemExtent is 40.0.
    // Delta = (24 - 10) * 40.0 = 14 * 40.0 = 560.0.

    final hourListFinder = find.byType(ListWheelScrollView).first;

    // Scroll by enough to reach index 24
    await tester.drag(hourListFinder, const Offset(0, -600));
    await tester.pumpAndSettle();

    // If the bug exists, this might crash or selectedTime might not be updated correctly.
    // If it crashes, the test will fail with an exception.

    // We expect the hour to be around 0 or whatever index 24 maps to.
    // Index 24 % 24 = 0.
    // If it didn't crash, selectedTime should be valid.
  });

  testWidgets('WheelTimePicker handles scrolling past 60 minutes correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WheelTimePicker(
            initialTime: const TimeOfDay(hour: 10, minute: 30),
            onTimeChanged: (time) {
              // Time change callback - just verify it doesn't crash
            },
          ),
        ),
      ),
    );

    // Scroll minute to index 60 (which should be minute 0)
    // Initial is 30. Target 60. Delta = 30 * 40 = 1200.

    final minuteListFinder = find.byType(ListWheelScrollView).last;

    await tester.drag(minuteListFinder, const Offset(0, -1300));
    await tester.pumpAndSettle();

    // Should not crash
  });
}
