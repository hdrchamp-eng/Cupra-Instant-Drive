import 'package:cupra_instant_drive/core/data/demo_seed.dart';
import 'package:cupra_instant_drive/core/models/models.dart';
import 'package:cupra_instant_drive/core/utils/discovery_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Alle aktuellen Modellreihen besitzen ein eigenes Fahrzeugbild', () {
    expect(demoVehicles.map((vehicle) => vehicle.model).toSet(), {
      'Raval',
      'Born',
      'Tavascan',
      'Leon',
      'Leon Sportstourer',
      'Formentor',
      'Terramar',
      'Ateca',
    });
    expect(
      demoVehicles.map((vehicle) => vehicle.imageAsset).toSet(),
      hasLength(8),
    );
  });

  test('Ort-, PLZ- und Antriebsfilter verändern die Resultate', () {
    final basel = filterAndSortVehicles(
      vehicles: demoVehicles,
      hubs: demoHubs,
      slotsFor: demoSlotsFor,
      query: '4051',
      availableOnly: true,
    );
    expect(
      basel.map((vehicle) => vehicle.id),
      containsAll(['veh-03', 'veh-06']),
    );

    final electric = filterAndSortVehicles(
      vehicles: demoVehicles,
      hubs: demoHubs,
      slotsFor: demoSlotsFor,
      powertrain: 'Elektro',
      availableOnly: false,
    );
    expect(
      electric.map((vehicle) => vehicle.id),
      containsAll(['veh-01', 'veh-02', 'veh-03']),
    );
    expect(
      electric.every((vehicle) => vehicle.powertrain == 'Elektro'),
      isTrue,
    );
  });

  test('Entfernung und Verfügbarkeit werden gemeinsam angewendet', () {
    final nearby = filterAndSortVehicles(
      vehicles: demoVehicles,
      hubs: demoHubs,
      slotsFor: demoSlotsFor,
      maxDistance: 2,
    );
    expect(
      nearby.map((vehicle) => vehicle.id),
      containsAll(['veh-01', 'veh-02', 'veh-04', 'veh-05']),
    );
  });

  test('Premium-Preissortierung berücksichtigt Performance-Aufpreis', () {
    final premium = filterAndSortVehicles(
      vehicles: demoVehicles,
      hubs: demoHubs,
      slotsFor: demoSlotsFor,
      availableOnly: true,
      sort: VehicleSort.price,
      drivePackage: DrivePackage.weekend,
    );
    expect(premium.last.performance, isTrue);
  });
}
