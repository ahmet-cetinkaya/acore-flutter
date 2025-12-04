import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acore/acore.dart';
import 'package:acore/components/date_time_picker/time_picker_mobile_content.dart';

void main() {
  testWidgets('TimeSelectionDialog responsive mode saves All Day option', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800); // Mobile size
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final config = TimeSelectionDialogConfig(
      selectedDate: DateTime(2023, 1, 1),
      initialTime: const TimeOfDay(hour: 10, minute: 0),
      translations: {
        DateTimePickerTranslationKey.selectTimeTitle: 'Select Time',
        DateTimePickerTranslationKey.confirm: 'Confirm',
        DateTimePickerTranslationKey.cancel: 'Cancel',
        DateTimePickerTranslationKey.allDay: 'All day',
      },
      useMobileScaffoldLayout: true,
      useResponsiveDialog: true,
      dialogSize: DialogSize.medium,
    );

    TimeSelectionResult? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  result = await TimeSelectionDialog.showResponsive(
                    context: context,
                    config: config,
                  );
                },
                child: const Text('Open Dialog'),
              );
            },
          ),
        ),
      ),
    );

    // Open dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Verify dialog is open
    expect(find.byType(TimePickerMobileContent), findsOneWidget);

    // Find All Day switch and toggle it
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    // Find "Done" button in AppBar
    final doneButton = find.byKey(const Key('time_picker_done_button'));
    expect(doneButton, findsOneWidget);

    // Tap Done
    await tester.tap(doneButton);
    await tester.pumpAndSettle();

    // Verify result
    expect(result, isNotNull);
    expect(result!.isConfirmed, isTrue);
    expect(result!.isAllDay, isTrue);
  });
}
