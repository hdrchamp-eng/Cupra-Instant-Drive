import 'dart:convert';
import 'dart:io';

import 'package:cupra_instant_drive/core/data/demo_seed.dart';

void main() {
  final seed = {
    'schemaVersion': 1,
    'generatedFor': 'CUPRA Instant Drive · fiktiver MVP',
    'hubs': [
      for (final hub in demoHubs)
        {
          'id': hub.id,
          'name': hub.name,
          'city': hub.city,
          'address': hub.address,
          'distanceKm': hub.distanceKm,
          'map': {'latitude': hub.latitude, 'longitude': hub.longitude},
          'hours': hub.hours,
          'parkingNote': hub.parkingNote,
        },
    ],
    'vehicles': [
      for (final vehicle in demoVehicles)
        {
          'id': vehicle.id,
          'model': vehicle.model,
          'variant': vehicle.variant,
          'powertrain': vehicle.powertrain,
          'power': vehicle.power,
          'range': vehicle.range,
          'seats': vehicle.seats,
          'hubId': vehicle.hubId,
          'status': vehicle.status.name,
          'features': vehicle.features,
          'performance': vehicle.performance,
          'imageAsset': vehicle.imageAsset,
        },
    ],
  };
  const encoder = JsonEncoder.withIndent('  ');
  stdout.writeln(encoder.convert(seed));
}
