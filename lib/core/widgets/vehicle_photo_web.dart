import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import 'vehicle_photo.dart';

String _cssGradient(LinearGradient gradient) {
  final start = gradient.begin.resolve(TextDirection.ltr);
  final end = gradient.end.resolve(TextDirection.ltr);
  final angle = math.atan2(end.x - start.x, start.y - end.y) * 180 / math.pi;
  final stops = <String>[];
  for (var i = 0; i < gradient.colors.length; i++) {
    final color = gradient.colors[i];
    final stop = gradient.stops?[i] ?? i / (gradient.colors.length - 1);
    stops.add(
      'rgba(${(color.r * 255).round()},${(color.g * 255).round()},'
      '${(color.b * 255).round()},${color.a}) ${stop * 100}%',
    );
  }
  return 'linear-gradient(${angle}deg,${stops.join(',')})';
}

Widget buildPhoto(VehiclePhoto photo) {
  final gradientCss = photo.gradients.reversed.map(_cssGradient).join(',');
  final position =
      '${(photo.alignment.x + 1) * 50}% ${(photo.alignment.y + 1) * 50}%';
  final fit = photo.fit == BoxFit.contain ? 'contain' : 'cover';
  return SizedBox(
    width: photo.width,
    height: photo.height,
    child: IgnorePointer(
      child: HtmlElementView.fromTagName(
        key: ValueKey('${photo.asset}|$position|$fit|$gradientCss'),
        tagName: 'div',
        onElementCreated: (element) {
          final host = element as web.HTMLDivElement;
          host.style.cssText = 'position:relative;width:100%;height:100%;overflow:hidden;pointer-events:none;';
          host.setAttribute('data-cupra-photo', photo.asset);
          host.setAttribute(
            'aria-hidden',
            photo.excludeFromSemantics ? 'true' : 'false',
          );
          final image = web.HTMLImageElement()
            ..src = Uri.base.resolve('assets/${photo.asset}').toString()
            ..alt = photo.excludeFromSemantics
                ? ''
                : (photo.semanticLabel ?? 'CUPRA Fahrzeug')
            ..decoding = 'async';
          image.style.cssText =
              'display:block;width:100%;height:100%;object-fit:$fit;object-position:$position;pointer-events:none;';
          host.append(image);
          if (gradientCss.isNotEmpty) {
            final overlay = web.HTMLDivElement();
            overlay.style.cssText =
                'position:absolute;inset:0;pointer-events:none;background:$gradientCss;';
            host.append(overlay);
          }
        },
      ),
    ),
  );
}
