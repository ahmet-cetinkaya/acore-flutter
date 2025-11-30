import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acore/components/date_time_picker/wheel_time_picker.dart';

void main() {
  testWidgets('WheelTimePicker updates time on scroll', (WidgetTester tester) async {
    TimeOfDay? selectedTime;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WheelTimePicker(
            initialTime: const TimeOfDay(hour: 10, minute: 0),
            onTimeChanged: (time) {
              selectedTime = time;
            },
          ),
        ),
      ),
    );

    // Verify initial state
    expect(find.text('10'), findsOneWidget);
    expect(find.text('00'), findsOneWidget);

    // Scroll hour wheel
    await tester.drag(find.text('10'), const Offset(0, -50));
    await tester.pumpAndSettle();

    // Verify time updated
    expect(selectedTime, isNotNull);
    expect(selectedTime!.hour, isNot(10));

    // Scroll minute wheel
    await tester.drag(find.text('00'), const Offset(0, -50));
    await tester.pumpAndSettle();

    // Verify minute updated
    expect(selectedTime!.minute, isNot(0));
  });
}
