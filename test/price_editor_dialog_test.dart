import 'package:cupra_instant_drive/core/widgets/price_editor_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final save in [true, false]) {
    testWidgets('Focused Weekend price dialog closes safely (save=$save)', (
      tester,
    ) async {
      int? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await showDialog<int>(
                    context: context,
                    builder: (_) => const PriceEditorDialog(
                      title: 'Wochenende Premium bearbeiten',
                      initialRappen: 7900,
                    ),
                  );
                },
                child: const Text('Preis bearbeiten'),
              ),
            ),
          ),
        ),
      );
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('Preis bearbeiten'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), '89,50');
        await tester.tap(find.text(save ? 'Speichern' : 'Abbrechen'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 80));
        expect(tester.takeException(), isNull);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(result, save ? 8950 : isNull);
      }
    });
  }
}
