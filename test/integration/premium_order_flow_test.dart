import 'package:cupra_instant_drive/app/app_state.dart';
import 'package:cupra_instant_drive/core/data/demo_seed.dart';
import 'package:cupra_instant_drive/core/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Premium-Buchung, Fahrt und fiktive Bestellung funktionieren', () async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await state.initialize();
    await state.demoLogin();
    await state.runVerification();
    final vehicle = demoVehicles.firstWhere((item) => item.performance);

    state.recordPayment(const PaymentSimulation('PAY-DEMO', 12800, true));
    final booking = state.createBooking(
      vehicle: vehicle,
      start: demoSlotsFor(vehicle.id).first.start,
      drivePackage: DrivePackage.weekend,
      homeDelivery: true,
    );
    expect(booking.priceRappen, 12800);
    expect(state.lastPayment?.approved, isTrue);

    for (var index = 0; index < 6; index++) {
      state.advanceTrip();
    }
    expect(state.tripStage, TripStage.completed);
    expect(state.bookings.first.status, BookingStatus.completed);

    final order = state.createOrder(
      vehicle: vehicle,
      mode: FinanceMode.subscription,
      colour: 'Copper Grey',
      termMonths: 36,
      insurance: true,
      tradeIn: true,
    );
    expect(order.reference, startsWith('ORDER-'));
    expect(order.totalRappen, 109900 * 36);
  });
}
