import 'dart:io';

import 'package:cupra_instant_drive/core/data/demo_seed.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Laufzeitbilder bleiben im Web-Performance-Budget', () async {
    final paths = <String>{
      'assets/images/demo_hero.jpg',
      ...demoVehicles.map((vehicle) => vehicle.imageAsset),
    };

    for (final path in paths) {
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: '$path fehlt');
      expect(
        await file.length(),
        lessThan(300 * 1024),
        reason: '$path ist grösser als 300 KB',
      );
    }
  });
}
