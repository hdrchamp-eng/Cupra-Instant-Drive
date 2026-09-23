import 'package:flutter/material.dart';

import 'vehicle_photo.dart';

Widget buildPhoto(VehiclePhoto photo) {
  final image = Image.asset(
    photo.asset,
    width: photo.width,
    height: photo.height,
    fit: photo.fit,
    alignment: photo.alignment,
    semanticLabel: photo.semanticLabel,
    excludeFromSemantics: photo.excludeFromSemantics,
    errorBuilder: photo.errorBuilder,
  );
  if (photo.gradients.isEmpty) return image;
  return Stack(
    fit: StackFit.expand,
    children: [
      image,
      for (final gradient in photo.gradients)
        DecoratedBox(decoration: BoxDecoration(gradient: gradient)),
    ],
  );
}
