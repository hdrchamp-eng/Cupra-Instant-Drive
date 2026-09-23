import 'package:cupra_instant_drive/core/widgets/smooth_wheel_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<SmoothWheelScrollController> mount(
    WidgetTester tester, {
    bool smooth = true,
  }) async {
    final controller = SmoothWheelScrollController(smoothWheel: smooth);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ListView.builder(
          controller: controller,
          itemExtent: 100,
          itemCount: 100,
          itemBuilder: (_, i) => Text('Row $i'),
        ),
      ),
    );
    return controller;
  }

  testWidgets('Wheel ticks interpolate instead of jumping a full step', (
    tester,
  ) async {
    final controller = await mount(tester);
    controller.position.pointerScroll(120);
    expect(controller.offset, 0);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    expect(controller.offset, greaterThan(0));
    expect(controller.offset, lessThan(120));
    await tester.pumpAndSettle();
    expect(controller.offset, closeTo(120, .01));
  });

  testWidgets(
    'Repeated wheel ticks preserve distance and reversal is immediate',
    (tester) async {
      final controller = await mount(tester);
      controller.position.pointerScroll(120);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      controller.position.pointerScroll(120);
      await tester.pumpAndSettle();
      expect(controller.offset, closeTo(240, .01));
      controller.position.pointerScroll(120);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      final beforeReversal = controller.offset;
      controller.position.pointerScroll(-120);
      await tester.pumpAndSettle();
      expect(controller.offset, closeTo(beforeReversal - 120, .01));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Wheel clamps to edges and a drag interrupts it', (tester) async {
    final controller = await mount(tester);
    controller.position.pointerScroll(-120);
    await tester.pumpAndSettle();
    expect(controller.offset, 0);
    controller.position.pointerScroll(100000);
    await tester.pumpAndSettle();
    expect(controller.offset, controller.position.maxScrollExtent);
    controller.jumpTo(400);
    controller.position.pointerScroll(120);
    await tester.pump();
    await tester.drag(find.byType(ListView), const Offset(0, 150));
    await tester.pumpAndSettle();
    expect(controller.offset, lessThan(400));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Disabled smoothing preserves native behaviour', (tester) async {
    final controller = await mount(tester, smooth: false);
    controller.position.pointerScroll(120);
    expect(controller.offset, 120);
    await tester.pumpAndSettle();
  });
}
