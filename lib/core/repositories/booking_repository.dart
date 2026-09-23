import '../models/models.dart';
import '../utils/booking_logic.dart';

abstract interface class BookingRepository {
  List<Booking> get all;
  bool isAvailable(String vehicleId, DateTime start, DrivePackage drivePackage);
  void add(Booking booking);
}

class LocalBookingRepository implements BookingRepository {
  final List<Booking> _items = [];
  @override
  List<Booking> get all => List.unmodifiable(_items);
  @override
  bool isAvailable(
    String vehicleId,
    DateTime start,
    DrivePackage drivePackage,
  ) => !_items.any(
    (b) =>
        b.vehicleId == vehicleId &&
        b.status != BookingStatus.cancelled &&
        bookingsOverlap(
          start,
          packageMinutes(drivePackage),
          b.start,
          packageMinutes(b.drivePackage),
        ),
  );
  @override
  void add(Booking booking) {
    if (!isAvailable(booking.vehicleId, booking.start, booking.drivePackage)) {
      throw StateError('Doppelbuchung verhindert');
    }
    _items.add(booking);
  }
}
