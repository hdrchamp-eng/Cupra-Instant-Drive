import '../models/models.dart';

int packagePriceRappen(
  DrivePackage drivePackage, {
  bool homeDelivery = false,
  bool performance = false,
}) {
  final base = switch (drivePackage) {
    DrivePackage.standard60 => 0,
    DrivePackage.extended90 => 2900,
    DrivePackage.weekend => 7900,
  };
  return base +
      (homeDelivery ? 3900 : 0) +
      (performance && drivePackage != DrivePackage.standard60 ? 1000 : 0);
}

bool bookingsOverlap(
  DateTime firstStart,
  int firstMinutes,
  DateTime secondStart,
  int secondMinutes,
) {
  final firstEnd = firstStart.add(Duration(minutes: firstMinutes));
  final secondEnd = secondStart.add(Duration(minutes: secondMinutes));
  return firstStart.isBefore(secondEnd) && secondStart.isBefore(firstEnd);
}

int packageMinutes(DrivePackage value) => switch (value) {
  DrivePackage.standard60 => 60,
  DrivePackage.extended90 => 90,
  DrivePackage.weekend => 48 * 60,
};

bool canTransitionBooking(BookingStatus from, BookingStatus to) =>
    switch ((from, to)) {
      (BookingStatus.confirmed, BookingStatus.checkedIn) => true,
      (BookingStatus.confirmed, BookingStatus.cancelled) => true,
      (BookingStatus.checkedIn, BookingStatus.active) => true,
      (BookingStatus.active, BookingStatus.completed) => true,
      _ => false,
    };

bool isWithinCheckInWindow(Booking booking, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final opensAt = booking.start.subtract(const Duration(minutes: 15));
  final closesAt = booking.start.add(
    Duration(minutes: packageMinutes(booking.drivePackage)),
  );
  return !current.isBefore(opensAt) && !current.isAfter(closesAt);
}

String chf(int rappen) => 'CHF ${(rappen / 100).toStringAsFixed(2)}';
