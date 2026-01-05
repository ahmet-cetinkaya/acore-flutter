import 'package:acore/components/date_time_picker/constants/date_time_picker_translation_keys.dart';
import 'package:acore/components/date_time_picker/date_picker_content.dart';
import 'package:acore/components/date_time_picker/models/date_picker_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DatePickerContent', () {
    testWidgets('Quick selection "No Date" clears range selection', (WidgetTester tester) async {
      DatePickerContentResult? lastResult;

      final config = DatePickerContentConfig(
        selectionMode: DateSelectionMode.range,
        initialStartDate: DateTime(2023, 1, 1),
        initialEndDate: DateTime(2023, 1, 5),
        onSelectionChanged: (result) {
          lastResult = result;
        },
        translations: {
          DateTimePickerTranslationKey.quickSelectionNoDate: 'No Date',
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DatePickerContent(config: config),
          ),
        ),
      );

      // Verify initial state
      expect(find.text('No Date'), findsOneWidget);

      // Tap "No Date" button (it has an 'x' icon and logic uses mapped text or key specific lookups,
      // but based on `DateSelectionUtils.getLocalizedText`, it should show "No Date")
      await tester.tap(find.text('No Date'));
      await tester.pump();

      // Verify that the selection was cleared
      expect(lastResult, isNotNull);
      expect(lastResult!.startDate, isNull);
      expect(lastResult!.endDate, isNull);
      expect(lastResult!.quickSelectionKey, equals('noDate'));
    });
  });
}
