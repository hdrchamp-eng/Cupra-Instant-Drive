import 'package:cupra_instant_drive/app/app_state.dart';
import 'package:cupra_instant_drive/core/data/demo_seed.dart';
import 'package:cupra_instant_drive/core/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'Buchung, Fahrt und Bestellung bleiben nach Neustart erhalten',
    () async {
      SharedPreferences.setMockInitialValues({});
      final state = AppState();
      await state.initialize();
      await state.demoLogin();
      await state.runVerification();

      final vehicle = demoVehicles.first;
      state.createBooking(
        vehicle: vehicle,
        start: demoSlotsFor(vehicle.id).first.start,
        drivePackage: DrivePackage.extended90,
        homeDelivery: true,
      );
      state.advanceTrip();
      state.createOrder(
        vehicle: vehicle,
        mode: FinanceMode.leasing,
        colour: 'Graphite',
        termMonths: 48,
        insurance: true,
        tradeIn: true,
      );
      await state.flushPersistence();

      final restored = AppState();
      await restored.initialize();
      expect(restored.loggedIn, isTrue);
      expect(restored.profile?.email, 'nina@demo.ch');
      expect(restored.bookings.single.drivePackage, DrivePackage.extended90);
      expect(restored.bookings.single.priceRappen, 6800);
      expect(restored.tripStage, TripStage.locationChecked);
      expect(restored.order?.mode, FinanceMode.leasing);
      expect(restored.audit, isNotEmpty);
    },
  );

  test('Beschädigte lokale JSON-Daten führen zu sicherem Fallback', () async {
    SharedPreferences.setMockInitialValues({
      'loggedIn': true,
      'bookings': '{kein-json',
      'tripStage': 999,
    });
    final state = AppState();
    await state.initialize();
    expect(state.initialized, isTrue);
    expect(state.loggedIn, isTrue);
    expect(state.profile, isNotNull);
    expect(state.bookings, isEmpty);
    expect(state.tripStage, TripStage.upcoming);
  });
}
