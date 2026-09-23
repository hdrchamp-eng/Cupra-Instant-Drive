import 'package:cupra_instant_drive/app/app.dart';
import 'package:cupra_instant_drive/core/widgets/vehicle_photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Landing scrolls through lazy sections with one scroll owner', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const InstantDriveApp());
    await tester.pumpAndSettle();
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(find.text('Impressum'), findsNothing);
    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('Impressum'),
      450,
      scrollable: scrollable,
      maxScrolls: 40,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Impressum'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('CUPRA in der Nähe finden'),
      -450,
      scrollable: scrollable,
      maxScrolls: 40,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final size in <Size>[
    const Size(390, 844),
    const Size(820, 1180),
    const Size(1440, 900),
  ]) {
    testWidgets(
      'Landingpage rendert ohne Fehler bei ${size.width.toInt()} px',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(const InstantDriveApp());
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('CUPRA in der Nähe finden'), findsOneWidget);
        final hero = tester.widget<VehiclePhoto>(
          find.byKey(const ValueKey('landing-background-car')),
        );
        expect(hero.fit, BoxFit.cover);
        expect(
          find.byKey(const ValueKey('landing-foreground-car')),
          findsNothing,
        );
        expect(
          find.byKey(const ValueKey('landing-background-hero')),
          findsOneWidget,
        );
        expect(hero.asset, 'assets/images/demo_hero.jpg');
      },
    );
  }

  testWidgets('Hauptnavigation und Marke besitzen verständliche Semantik', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(const InstantDriveApp());
    await tester.pumpAndSettle();
    expect(
      find.bySemanticsLabel('CUPRA Instant Drive, fiktiver Prototyp'),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, 'Demo starten'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('Discovery zeigt mobil alle acht Modelle ohne Layoutfehler', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const InstantDriveApp());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('CUPRA in der Nähe finden'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CUPRA in der Nähe finden'));
    await tester.pumpAndSettle();
    expect(find.text('CUPRA in deiner Nähe'), findsOneWidget);
    expect(find.textContaining('8 Fahrzeuge'), findsOneWidget);
    await tester.tap(find.text('Karte'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Interaktive Karte'), findsOneWidget);
    expect(find.byTooltip('Hineinzoomen'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('cupra-map-pin-hub-zrh-hb')),
      findsOneWidget,
    );
  });
}
