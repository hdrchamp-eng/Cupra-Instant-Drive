import 'package:cupra_instant_drive/app/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Landingpage zeigt primären CTA und Demo-Hinweis', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const InstantDriveApp());
    await tester.pumpAndSettle();
    expect(find.text('Einsteigen.\nTesten. Verlieben.'), findsOneWidget);
    expect(find.text('CUPRA in der Nähe finden'), findsOneWidget);
    expect(find.textContaining('FIKTIVER MVP'), findsOneWidget);
  });
}
