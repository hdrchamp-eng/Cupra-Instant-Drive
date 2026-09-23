enum VerificationStatus { notStarted, reviewing, verified, rejected }

enum VehicleStatus {
  available,
  reserved,
  inTrip,
  cleaning,
  charging,
  maintenance,
  offline,
}

enum BookingStatus { confirmed, checkedIn, active, completed, cancelled }

enum DrivePackage { standard60, extended90, weekend }

enum FinanceMode { purchase, leasing, subscription }

enum TripStage {
  upcoming,
  locationChecked,
  damageChecked,
  unlocked,
  active,
  returning,
  completed,
}

class User {
  const User({
    required this.id,
    required this.email,
    required this.createdAt,
    this.isAdmin = false,
  });

  final String id;
  final String email;
  final DateTime createdAt;
  final bool isAdmin;
}

class Hub {
  const Hub({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.distanceKm,
    required this.latitude,
    required this.longitude,
    required this.hours,
    required this.parkingNote,
  });
  final String id;
  final String name;
  final String city;
  final String address;
  final double distanceKm;
  final double latitude;
  final double longitude;
  final String hours;
  final String parkingNote;
}

class Vehicle {
  const Vehicle({
    required this.id,
    required this.model,
    required this.variant,
    required this.powertrain,
    required this.power,
    required this.range,
    required this.seats,
    required this.hubId,
    required this.status,
    required this.accent,
    required this.features,
    this.imageAsset = 'assets/images/demo_hero.jpg',
    this.performance = false,
  });
  final String id;
  final String model;
  final String variant;
  final String powertrain;
  final String power;
  final String range;
  final int seats;
  final String hubId;
  final VehicleStatus status;
  final int accent;
  final List<String> features;
  final String imageAsset;
  final bool performance;
}

class VehicleImage {
  const VehicleImage({
    required this.id,
    required this.vehicleId,
    required this.assetPath,
    required this.altText,
  });

  final String id;
  final String vehicleId;
  final String assetPath;
  final String altText;
}

class AvailabilitySlot {
  const AvailabilitySlot({
    required this.id,
    required this.vehicleId,
    required this.start,
    required this.end,
  });
  final String id;
  final String vehicleId;
  final DateTime start;
  final DateTime end;
}

class Booking {
  const Booking({
    required this.id,
    required this.reference,
    required this.vehicleId,
    required this.hubId,
    required this.start,
    required this.drivePackage,
    required this.priceRappen,
    required this.status,
    required this.homeDelivery,
  });
  final String id;
  final String reference;
  final String vehicleId;
  final String hubId;
  final DateTime start;
  final DrivePackage drivePackage;
  final int priceRappen;
  final BookingStatus status;
  final bool homeDelivery;

  Booking copyWith({BookingStatus? status}) => Booking(
    id: id,
    reference: reference,
    vehicleId: vehicleId,
    hubId: hubId,
    start: start,
    drivePackage: drivePackage,
    priceRappen: priceRappen,
    status: status ?? this.status,
    homeDelivery: homeDelivery,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'reference': reference,
    'vehicleId': vehicleId,
    'hubId': hubId,
    'start': start.toIso8601String(),
    'drivePackage': drivePackage.name,
    'priceRappen': priceRappen,
    'status': status.name,
    'homeDelivery': homeDelivery,
  };

  factory Booking.fromJson(Map<String, Object?> json) => Booking(
    id: json['id']! as String,
    reference: json['reference']! as String,
    vehicleId: json['vehicleId']! as String,
    hubId: json['hubId']! as String,
    start: DateTime.parse(json['start']! as String),
    drivePackage: DrivePackage.values.byName(json['drivePackage']! as String),
    priceRappen: json['priceRappen']! as int,
    status: BookingStatus.values.byName(json['status']! as String),
    homeDelivery: json['homeDelivery']! as bool,
  );
}

class VehicleOrder {
  const VehicleOrder({
    required this.reference,
    required this.vehicleId,
    required this.mode,
    required this.colour,
    required this.termMonths,
    required this.insurance,
    required this.tradeIn,
    required this.totalRappen,
    required this.createdAt,
  });
  final String reference;
  final String vehicleId;
  final FinanceMode mode;
  final String colour;
  final int termMonths;
  final bool insurance;
  final bool tradeIn;
  final int totalRappen;
  final DateTime createdAt;

  Map<String, Object?> toJson() => {
    'reference': reference,
    'vehicleId': vehicleId,
    'mode': mode.name,
    'colour': colour,
    'termMonths': termMonths,
    'insurance': insurance,
    'tradeIn': tradeIn,
    'totalRappen': totalRappen,
    'createdAt': createdAt.toIso8601String(),
  };

  factory VehicleOrder.fromJson(Map<String, Object?> json) => VehicleOrder(
    reference: json['reference']! as String,
    vehicleId: json['vehicleId']! as String,
    mode: FinanceMode.values.byName(json['mode']! as String),
    colour: json['colour']! as String,
    termMonths: json['termMonths']! as int,
    insurance: json['insurance']! as bool,
    tradeIn: json['tradeIn']! as bool,
    totalRappen: json['totalRappen']! as int,
    createdAt: DateTime.parse(json['createdAt']! as String),
  );
}

class UserProfile {
  const UserProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobile,
    required this.address,
    required this.birthDate,
  });
  final String firstName;
  final String lastName;
  final String email;
  final String mobile;
  final String address;
  final DateTime birthDate;

  Map<String, Object?> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'mobile': mobile,
    'address': address,
    'birthDate': birthDate.toIso8601String(),
  };

  factory UserProfile.fromJson(Map<String, Object?> json) => UserProfile(
    firstName: json['firstName']! as String,
    lastName: json['lastName']! as String,
    email: json['email']! as String,
    mobile: json['mobile']! as String,
    address: json['address']! as String,
    birthDate: DateTime.parse(json['birthDate']! as String),
  );
}

class DriverVerification {
  const DriverVerification(this.status, this.updatedAt);
  final VerificationStatus status;
  final DateTime? updatedAt;
}

class BookingAddon {
  const BookingAddon(this.id, this.name, this.priceRappen);
  final String id;
  final String name;
  final int priceRappen;
}

class PaymentSimulation {
  const PaymentSimulation(this.reference, this.amountRappen, this.approved);
  final String reference;
  final int amountRappen;
  final bool approved;
}

class CheckIn {
  const CheckIn(this.bookingId, this.stage);
  final String bookingId;
  final TripStage stage;
}

class DamageReport {
  const DamageReport(this.bookingId, this.hasDamage, this.note);
  final String bookingId;
  final bool hasDamage;
  final String note;
}

class Trip {
  const Trip(this.bookingId, this.startedAt, this.endsAt);
  final String bookingId;
  final DateTime startedAt;
  final DateTime endsAt;
}

class ReturnInspection {
  const ReturnInspection(this.bookingId, this.completedAt, this.chargePercent);
  final String bookingId;
  final DateTime completedAt;
  final int chargePercent;
}

class Favorite {
  const Favorite(this.vehicleId);
  final String vehicleId;
}

class Feedback {
  const Feedback(this.bookingId, this.csat, this.nps, this.comment);
  final String bookingId;
  final int csat;
  final int nps;
  final String comment;
}

class Offer {
  const Offer(this.vehicleId, this.mode, this.monthlyRappen);
  final String vehicleId;
  final FinanceMode mode;
  final int monthlyRappen;
}

class InsuranceSelection {
  const InsuranceSelection(this.selected, this.monthlyRappen);
  final bool selected;
  final int monthlyRappen;
}

class TradeInEstimate {
  const TradeInEstimate(this.vehicleDescription, this.estimateRappen);
  final String vehicleDescription;
  final int estimateRappen;
}

class NotificationItem {
  const NotificationItem(this.title, this.body, this.createdAt);
  final String title;
  final String body;
  final DateTime createdAt;
}

class AuditEvent {
  const AuditEvent(this.action, this.createdAt);
  final String action;
  final DateTime createdAt;

  Map<String, Object?> toJson() => {
    'action': action,
    'createdAt': createdAt.toIso8601String(),
  };

  factory AuditEvent.fromJson(Map<String, Object?> json) => AuditEvent(
    json['action']! as String,
    DateTime.parse(json['createdAt']! as String),
  );
}
