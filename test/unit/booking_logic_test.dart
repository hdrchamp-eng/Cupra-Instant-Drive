import 'package:cupra_instant_drive/core/models/models.dart';
import 'package:cupra_instant_drive/core/utils/booking_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Preisberechnung', () {
    test(
      'Standardfahrt bleibt CHF 0.00',
      () => expect(packagePriceRappen(DrivePackage.standard60), 0),
    );
    test(
      'Premium und Lieferung werden transparent addiert',
      () => expect(
        packagePriceRappen(DrivePackage.extended90, homeDelivery: true),
        6800,
      ),
    );
    test(
      'Performance-Aufpreis gilt nur für Premium',
      () => expect(
        packagePriceRappen(DrivePackage.weekend, performance: true),
        8900,
      ),
    );
  });
  group('Verfügbarkeit', () {
    final start = DateTime(2026, 10, 1, 9);
    test(
      'Überlappung wird erkannt',
      () => expect(
        bookingsOverlap(start, 60, start.add(const Duration(minutes: 30)), 60),
        isTrue,
      ),
    );
    test(
      'Direkt anschliessendes Zeitfenster ist frei',
      () => expect(
        bookingsOverlap(start, 60, start.add(const Duration(minutes: 60)), 60),
        isFalse,
      ),
    );
  });
  test('Nur erlaubte Buchungsstatuswechsel werden akzeptiert', () {
    expect(
      canTransitionBooking(BookingStatus.confirmed, BookingStatus.checkedIn),
      isTrue,
    );
    expect(
      canTransitionBooking(BookingStatus.confirmed, BookingStatus.completed),
      isFalse,
    );
  });

  test('Check-in öffnet 15 Minuten vorher und schliesst nach der Fahrt', () {
    final start = DateTime(2026, 10, 1, 9);
    final booking = Booking(
      id: 'booking-window',
      reference: 'CID-WINDOW',
      vehicleId: 'veh-01',
      hubId: 'hub-zrh-hb',
      start: start,
      drivePackage: DrivePackage.standard60,
      priceRappen: 0,
      status: BookingStatus.confirmed,
      homeDelivery: false,
    );
    expect(
      isWithinCheckInWindow(
        booking,
        now: start.subtract(const Duration(minutes: 16)),
      ),
      isFalse,
    );
    expect(
      isWithinCheckInWindow(
        booking,
        now: start.subtract(const Duration(minutes: 15)),
      ),
      isTrue,
    );
    expect(
      isWithinCheckInWindow(
        booking,
        now: start.add(const Duration(minutes: 61)),
      ),
      isFalse,
    );
  });
}
