import 'package:cupra_instant_drive/app/app.dart';
import 'package:cupra_instant_drive/app/app_state.dart';
import 'package:cupra_instant_drive/core/data/demo_seed.dart';
import 'package:cupra_instant_drive/core/design/app_theme.dart';
import 'package:cupra_instant_drive/core/models/models.dart';
import 'package:cupra_instant_drive/features/booking_auth.dart';
import 'package:cupra_instant_drive/features/dashboard_trip_order.dart';
import 'package:cupra_instant_drive/features/landing_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget scoped(AppState state, Widget home) => AppScope(
  state: state,
  child: MaterialApp(theme: buildAppTheme(), home: home),
);

void usePhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('Registrierung enthält alle geforderten Profildaten', (
    tester,
  ) async {
    usePhoneViewport(tester);
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await state.initialize();
    await tester.pumpWidget(scoped(state, const AuthScreen(initialTab: 1)));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Vorname'), findsOneWidget);
    expect(find.text('Nachname'), findsOneWidget);
    expect(find.text('Mobilnummer'), findsOneWidget);
    expect(find.text('Adresse'), findsOneWidget);
    expect(find.text('Geburtsdatum'), findsOneWidget);
    expect(find.text('Datenschutz akzeptieren'), findsOneWidget);
  });

  testWidgets('Fahrtenbereich bleibt ohne Anmeldung geschützt', (tester) async {
    usePhoneViewport(tester);
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await state.initialize();
    await tester.pumpWidget(scoped(state, const MainShell(initialIndex: 1)));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Deine Fahrten sind geschützt'), findsOneWidget);
  });

  testWidgets('Buchungs- und Bestellbestätigung rendern mobil', (tester) async {
    usePhoneViewport(tester);
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await state.initialize();
    await state.demoLogin();
    final vehicle = demoVehicles.first;
    final booking = state.createBooking(
      vehicle: vehicle,
      start: demoSlotsFor(vehicle.id).first.start,
      drivePackage: DrivePackage.standard60,
      homeDelivery: false,
    );
    await tester.pumpWidget(
      scoped(state, BookingConfirmationScreen(booking: booking)),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Deine Probefahrt ist bereit.'), findsOneWidget);
    final confirmationImage = find.byKey(
      const ValueKey('booking-confirmation-vehicle-image'),
    );
    expect(confirmationImage, findsOneWidget);
    final imageWidget = tester.widget<Image>(confirmationImage);
    expect((imageWidget.image as AssetImage).assetName, vehicle.imageAsset);
    await tester.scrollUntilVisible(
      find.text('Zu meinen Buchungen'),
      350,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Zu meinen Buchungen'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final order = state.createOrder(
      vehicle: vehicle,
      mode: FinanceMode.leasing,
      colour: 'Graphite',
      termMonths: 48,
      insurance: true,
      tradeIn: false,
    );
    await tester.pumpWidget(
      scoped(state, OrderConfirmationScreen(order: order)),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Demo-Bestellung bestätigt'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pump();
    expect(find.text('Nächste Schritte'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
