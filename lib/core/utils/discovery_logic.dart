import '../models/models.dart';
import 'booking_logic.dart';

enum VehicleSort { distance, earliestAvailability, price }

String vehicleSortLabel(VehicleSort value) => switch (value) {
  VehicleSort.distance => 'Entfernung',
  VehicleSort.earliestAvailability => 'Früheste Verfügbarkeit',
  VehicleSort.price => 'Preis',
};

List<Vehicle> filterAndSortVehicles({
  required List<Vehicle> vehicles,
  required List<Hub> hubs,
  required List<AvailabilitySlot> Function(String vehicleId) slotsFor,
  String query = '',
  String model = 'Alle',
  String powertrain = 'Alle',
  bool availableOnly = true,
  double maxDistance = double.infinity,
  VehicleSort sort = VehicleSort.distance,
  DrivePackage? drivePackage,
  bool homeDelivery = false,
}) {
  final normalizedQuery = query.trim().toLowerCase();
  Hub hubFor(Vehicle vehicle) =>
      hubs.firstWhere((hub) => hub.id == vehicle.hubId);

  final results = vehicles.where((vehicle) {
    final hub = hubFor(vehicle);
    final searchable =
        '${vehicle.model} ${vehicle.variant} ${hub.name} ${hub.city} ${hub.address}'
            .toLowerCase();
    return searchable.contains(normalizedQuery) &&
        (model == 'Alle' || vehicle.model == model) &&
        (powertrain == 'Alle' || vehicle.powertrain.contains(powertrain)) &&
        hub.distanceKm <= maxDistance &&
        (!availableOnly || vehicle.status == VehicleStatus.available);
  }).toList();

  results.sort((first, second) {
    switch (sort) {
      case VehicleSort.earliestAvailability:
        return slotsFor(first.id).first.start
            .compareTo(slotsFor(second.id).first.start);
      case VehicleSort.price:
        final selectedPackage = drivePackage ?? DrivePackage.standard60;
        return packagePriceRappen(
          selectedPackage,
          performance: first.performance,
          homeDelivery: homeDelivery,
        ).compareTo(
          packagePriceRappen(
            selectedPackage,
            performance: second.performance,
            homeDelivery: homeDelivery,
          ),
        );
      case VehicleSort.distance:
        return hubFor(first).distanceKm.compareTo(hubFor(second).distanceKm);
    }
  });
  return results;
}
