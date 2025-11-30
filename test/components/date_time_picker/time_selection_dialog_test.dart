import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acore/acore.dart';

void main() {
  testWidgets('TimeSelectionDialog shows time picker when All Day is unchecked', (WidgetTester tester) async {
    // Setup
    final config = TimeSelectionDialogConfig(
      selectedDate: DateTime(2023, 1, 1),
      initialTime: const TimeOfDay(hour: 10, minute: 0),
      translations: {
        DateTimePickerTranslationKey.selectTimeTitle: 'Select Time',
        DateTimePickerTranslationKey.confirm: 'Confirm',
        DateTimePickerTranslationKey.cancel: 'Cancel',
        DateTimePickerTranslationKey.allDay: 'All day',
      },
      initialIsAllDay: true,
      useResponsiveDialog: true,
      useMobileScaffoldLayout: true,
      dialogSize: DialogSize.medium,
    );

    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () {
                TimeSelectionDialog.showResponsive(
                  context: context,
                  config: config,
                );
              },
              child: const Text('Open Dialog'),
            );
          },
        ),
      ),
    );

    // Open dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Verify initial state (All Day unchecked by default in code, time picker visible)
    expect(find.text('All day'), findsOneWidget);
    expect(find.byType(Checkbox), findsOneWidget);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
    expect(find.byType(ListWheelScrollView), findsWidgets);

    // Check All Day
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    // Verify state after checking (All Day checked, time picker hidden)
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    expect(find.byType(ListWheelScrollView), findsNothing);

    // Uncheck All Day again
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    // Verify state after unchecking (All Day unchecked, time picker visible)
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
    expect(find.byType(ListWheelScrollView), findsWidgets); // Should find hour and minute wheels
  });
}
