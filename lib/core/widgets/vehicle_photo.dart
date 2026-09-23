import 'package:flutter/material.dart';

import 'vehicle_photo_native.dart'
    if (dart.library.js_interop) 'vehicle_photo_web.dart'
    as platform;

/// Photos use browser-composited DOM on web and ordinary Flutter images on iOS.
class VehiclePhoto extends StatelessWidget {
  const VehiclePhoto(
    this.asset, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.errorBuilder,
    this.gradients = const [],
  });

  final String asset;
  final double? width, height;
  final BoxFit fit;
  final Alignment alignment;
  final String? semanticLabel;
  final bool excludeFromSemantics;
  final ImageErrorWidgetBuilder? errorBuilder;
  final List<LinearGradient> gradients;

  @override
  Widget build(BuildContext context) => platform.buildPhoto(this);
}
