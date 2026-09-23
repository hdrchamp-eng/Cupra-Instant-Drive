import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/data/demo_seed.dart';
import '../core/models/models.dart';
import '../core/utils/booking_logic.dart';

class AppState extends ChangeNotifier {
  static const storageSchemaVersion = 1;

  bool initialized = false;
  bool loggedIn = false;
  bool isAdmin = false;
  UserProfile? profile;
  VerificationStatus verificationStatus = VerificationStatus.notStarted;
  final Set<String> favoriteIds = {};
  final List<Booking> bookings = [];
  VehicleOrder? order;
  PaymentSimulation? lastPayment;
  TripStage tripStage = TripStage.upcoming;
  final List<AuditEvent> audit = [];

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    loggedIn = prefs.getBool('loggedIn') ?? false;
    isAdmin = prefs.getBool('isAdmin') ?? false;
    final verificationIndex = prefs.getInt('verification') ?? 0;
    verificationStatus = verificationIndex < VerificationStatus.values.length
        ? VerificationStatus.values[verificationIndex]
        : VerificationStatus.notStarted;
    favoriteIds.addAll(prefs.getStringList('favorites') ?? const []);
    _restoreSession(prefs);
    initialized = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggedIn', loggedIn);
    await prefs.setBool('isAdmin', isAdmin);
    await prefs.setInt('verification', verificationStatus.index);
    await prefs.setStringList('favorites', favoriteIds.toList());
    await prefs.setInt('storageSchemaVersion', storageSchemaVersion);
    if (profile case final value?) {
      await prefs.setString('profile', jsonEncode(value.toJson()));
    } else {
      await prefs.remove('profile');
    }
    await prefs.setString(
      'bookings',
      jsonEncode(bookings.map((booking) => booking.toJson()).toList()),
    );
    await prefs.setInt('tripStage', tripStage.index);
    await prefs.setString(
      'audit',
      jsonEncode(audit.map((event) => event.toJson()).toList()),
    );
    if (order case final value?) {
      await prefs.setString('order', jsonEncode(value.toJson()));
    } else {
      await prefs.remove('order');
    }
  }

  @visibleForTesting
  Future<void> flushPersistence() => _persist();

  void _restoreSession(SharedPreferences prefs) {
    try {
      final profileJson = prefs.getString('profile');
      if (profileJson != null) {
        profile = UserProfile.fromJson(
          Map<String, Object?>.from(jsonDecode(profileJson) as Map),
        );
      } else if (loggedIn) {
        profile = _defaultProfile(isAdmin: isAdmin);
      }

      final bookingJson = prefs.getString('bookings');
      if (bookingJson != null) {
        bookings
          ..clear()
          ..addAll(
            (jsonDecode(bookingJson) as List).map(
              (value) =>
                  Booking.fromJson(Map<String, Object?>.from(value as Map)),
            ),
          );
      }

      final stageIndex = prefs.getInt('tripStage') ?? 0;
      tripStage = stageIndex < TripStage.values.length
          ? TripStage.values[stageIndex]
          : TripStage.upcoming;

      final orderJson = prefs.getString('order');
      if (orderJson != null) {
        order = VehicleOrder.fromJson(
          Map<String, Object?>.from(jsonDecode(orderJson) as Map),
        );
      }

      final auditJson = prefs.getString('audit');
      if (auditJson != null) {
        audit
          ..clear()
          ..addAll(
            (jsonDecode(auditJson) as List).map(
              (value) =>
                  AuditEvent.fromJson(Map<String, Object?>.from(value as Map)),
            ),
          );
      }
    } on FormatException catch (_) {
      _clearInvalidSession();
    } on TypeError catch (_) {
      _clearInvalidSession();
    } on ArgumentError catch (_) {
      _clearInvalidSession();
    }
  }

  void _clearInvalidSession() {
    profile = loggedIn ? _defaultProfile(isAdmin: isAdmin) : null;
    bookings.clear();
    order = null;
    tripStage = TripStage.upcoming;
    audit.clear();
  }

  static UserProfile _defaultProfile({required bool isAdmin}) => UserProfile(
    firstName: isAdmin ? 'Admin' : 'Nina',
    lastName: 'Muster',
    email: isAdmin ? 'admin@demo.ch' : 'nina@demo.ch',
    mobile: '+41 79 555 01 24',
    address: 'Lagerstrasse 18, 8004 Zürich',
    birthDate: DateTime(1993, 6, 18),
  );

  Future<void> demoLogin({bool admin = false}) async {
    loggedIn = true;
    isAdmin = admin;
    profile = _defaultProfile(isAdmin: admin);
    audit.add(
      AuditEvent(
        admin ? 'Demo-Admin angemeldet' : 'Demo-Nutzer angemeldet',
        DateTime.now(),
      ),
    );
    await _persist();
    notifyListeners();
  }

  Future<void> register(UserProfile value) async {
    profile = value;
    loggedIn = true;
    audit.add(AuditEvent('Demo-Konto erstellt', DateTime.now()));
    await _persist();
    notifyListeners();
  }

  Future<void> logout() async {
    loggedIn = false;
    isAdmin = false;
    profile = null;
    verificationStatus = VerificationStatus.notStarted;
    favoriteIds.clear();
    bookings.clear();
    order = null;
    lastPayment = null;
    tripStage = TripStage.upcoming;
    audit.clear();
    await _persist();
    notifyListeners();
  }

  Future<void> runVerification() async {
    verificationStatus = VerificationStatus.reviewing;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 700));
    verificationStatus = VerificationStatus.verified;
    audit.add(AuditEvent('Demo-Verifizierung erfolgreich', DateTime.now()));
    await _persist();
    notifyListeners();
  }

  Future<void> rejectVerification() async {
    verificationStatus = VerificationStatus.rejected;
    audit.add(AuditEvent('Demo-Verifizierung abgelehnt', DateTime.now()));
    await _persist();
    notifyListeners();
  }

  void toggleFavorite(String vehicleId) {
    favoriteIds.contains(vehicleId)
        ? favoriteIds.remove(vehicleId)
        : favoriteIds.add(vehicleId);
    _persist();
    notifyListeners();
  }

  Booking createBooking({
    required Vehicle vehicle,
    required DateTime start,
    required DrivePackage drivePackage,
    required bool homeDelivery,
  }) {
    final minutes = packageMinutes(drivePackage);
    final collision = bookings.any(
      (b) =>
          b.vehicleId == vehicle.id &&
          b.status != BookingStatus.cancelled &&
          bookingsOverlap(
            start,
            minutes,
            b.start,
            packageMinutes(b.drivePackage),
          ),
    );
    if (collision) throw StateError('Dieses Zeitfenster ist bereits gebucht.');
    final stamp = DateTime.now().millisecondsSinceEpoch.toString();
    final booking = Booking(
      id: 'booking-$stamp',
      reference: 'CID-${stamp.substring(stamp.length - 6)}',
      vehicleId: vehicle.id,
      hubId: vehicle.hubId,
      start: start,
      drivePackage: drivePackage,
      priceRappen: packagePriceRappen(
        drivePackage,
        homeDelivery: homeDelivery,
        performance: vehicle.performance,
      ),
      status: BookingStatus.confirmed,
      homeDelivery: homeDelivery,
    );
    bookings.insert(0, booking);
    audit.add(
      AuditEvent('Buchung ${booking.reference} erstellt', DateTime.now()),
    );
    unawaited(_persist());
    notifyListeners();
    return booking;
  }

  void cancelBooking(String id) {
    final index = bookings.indexWhere((b) => b.id == id);
    if (index < 0) return;
    bookings[index] = bookings[index].copyWith(status: BookingStatus.cancelled);
    audit.add(AuditEvent('Buchung storniert', DateTime.now()));
    unawaited(_persist());
    notifyListeners();
  }

  void adminSetBookingStatus(String id, BookingStatus status) {
    final index = bookings.indexWhere((booking) => booking.id == id);
    if (index < 0) return;
    bookings[index] = bookings[index].copyWith(status: status);
    audit.add(
      AuditEvent('Admin: Buchungsstatus auf ${status.name}', DateTime.now()),
    );
    unawaited(_persist());
    notifyListeners();
  }

  void adminDeleteBooking(String id) {
    final index = bookings.indexWhere((booking) => booking.id == id);
    if (index < 0) return;
    final removed = bookings.removeAt(index);
    audit.add(
      AuditEvent(
        'Admin: Buchung ${removed.reference} gelöscht',
        DateTime.now(),
      ),
    );
    unawaited(_persist());
    notifyListeners();
  }

  void recordPayment(PaymentSimulation payment) {
    lastPayment = payment;
    audit.add(
      AuditEvent(
        'Zahlungssimulation ${payment.reference}: ${payment.amountRappen} Rappen',
        DateTime.now(),
      ),
    );
    unawaited(_persist());
    notifyListeners();
  }

  void advanceTrip() {
    tripStage = switch (tripStage) {
      TripStage.upcoming => TripStage.locationChecked,
      TripStage.locationChecked => TripStage.damageChecked,
      TripStage.damageChecked => TripStage.unlocked,
      TripStage.unlocked => TripStage.active,
      TripStage.active => TripStage.returning,
      TripStage.returning => TripStage.completed,
      TripStage.completed => TripStage.completed,
    };
    if (bookings.isNotEmpty) {
      final target = switch (tripStage) {
        TripStage.unlocked => BookingStatus.checkedIn,
        TripStage.active => BookingStatus.active,
        TripStage.completed => BookingStatus.completed,
        _ => bookings.first.status,
      };
      bookings[0] = bookings.first.copyWith(status: target);
    }
    audit.add(AuditEvent('Fahrtstatus: ${tripStage.name}', DateTime.now()));
    unawaited(_persist());
    notifyListeners();
  }

  VehicleOrder createOrder({
    required Vehicle vehicle,
    required FinanceMode mode,
    required String colour,
    required int termMonths,
    required bool insurance,
    required bool tradeIn,
  }) {
    final monthly = switch (mode) {
      FinanceMode.purchase => 5690000,
      FinanceMode.leasing => 64900 * termMonths,
      FinanceMode.subscription => 109900 * termMonths,
    };
    order = VehicleOrder(
      reference:
          'ORDER-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      vehicleId: vehicle.id,
      mode: mode,
      colour: colour,
      termMonths: termMonths,
      insurance: insurance,
      tradeIn: tradeIn,
      totalRappen: monthly,
      createdAt: DateTime.now(),
    );
    audit.add(
      AuditEvent(
        'Unverbindliche Bestellung ${order!.reference}',
        DateTime.now(),
      ),
    );
    unawaited(_persist());
    notifyListeners();
    return order!;
  }

  Vehicle vehicleById(String id) => demoVehicles.firstWhere((v) => v.id == id);
  Hub hubById(String id) => demoHubs.firstWhere((h) => h.id == id);
}
