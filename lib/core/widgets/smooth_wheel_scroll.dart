import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Keeps native touch/trackpad drags, but interpolates discrete web wheel ticks.
/// No global event listener: nested controls and maps retain their own input.
class SmoothWheelScrollController extends ScrollController {
  SmoothWheelScrollController({this.smoothWheel = kIsWeb});

  bool smoothWheel;

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) => _WheelPosition(
    owner: this,
    physics: physics,
    context: context,
    oldPosition: oldPosition,
  );
}

class _WheelPosition extends ScrollPositionWithSingleContext {
  _WheelPosition({
    required this.owner,
    required super.physics,
    required super.context,
    super.oldPosition,
  });

  final SmoothWheelScrollController owner;
  double? _target;
  int _generation = 0;

  @override
  void pointerScroll(double delta) {
    if (!owner.smoothWheel || delta == 0) {
      _target = null;
      _generation++;
      super.pointerScroll(delta);
      return;
    }
    // A touch drag, scrollbar drag, or keyboard action cancels a wheel run.
    final pending = activity is DrivenScrollActivity ? _target : null;
    final sameDirection = pending != null && (pending - pixels) * delta > 0;
    final origin = sameDirection ? pending : pixels;
    final target = (origin + delta).clamp(minScrollExtent, maxScrollExtent);
    _target = target;
    final generation = ++_generation;
    animateTo(
      target,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
    ).whenComplete(() {
      if (_generation == generation) _target = null;
    });
  }
}

/// Owns a controller for exactly one viewport and honours reduced motion.
class SmoothWheelViewport extends StatefulWidget {
  const SmoothWheelViewport({required this.builder, super.key});

  final Widget Function(ScrollController controller) builder;

  @override
  State<SmoothWheelViewport> createState() => _SmoothWheelViewportState();
}

class _SmoothWheelViewportState extends State<SmoothWheelViewport> {
  final controller = SmoothWheelScrollController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controller.smoothWheel = kIsWeb && !MediaQuery.disableAnimationsOf(context);
    return widget.builder(controller);
  }
}
