import 'package:cupra_instant_drive/app/app_state.dart';
import 'package:cupra_instant_drive/core/data/demo_seed.dart';
import 'package:cupra_instant_drive/core/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Demo-Login, Verifizierung, Buchung und Doppelbuchungsschutz', () async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await state.initialize();
    await state.demoLogin();
    await state.runVerification();
    final vehicle = demoVehicles.first;
    final start = demoSlotsFor(vehicle.id).first.start;
    final booking = state.createBooking(
      vehicle: vehicle,
      start: start,
      drivePackage: DrivePackage.standard60,
      homeDelivery: false,
    );
    expect(state.loggedIn, isTrue);
    expect(state.verificationStatus, VerificationStatus.verified);
    expect(booking.priceRappen, 0);
    expect(
      () => state.createBooking(
        vehicle: vehicle,
        start: start,
        drivePackage: DrivePackage.extended90,
        homeDelivery: false,
      ),
      throwsStateError,
    );
  });
}
