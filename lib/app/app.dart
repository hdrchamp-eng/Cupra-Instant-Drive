import 'package:flutter/material.dart';

import '../core/design/app_theme.dart';
import '../features/landing_discovery.dart';
import 'app_state.dart';

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({required AppState state, required super.child, super.key})
    : super(notifier: state);
  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

class InstantDriveApp extends StatefulWidget {
  const InstantDriveApp({super.key});
  @override
  State<InstantDriveApp> createState() => _InstantDriveAppState();
}

class _InstantDriveAppState extends State<InstantDriveApp> {
  final AppState state = AppState();

  @override
  void initState() {
    super.initState();
    state.initialize();
  }

  @override
  Widget build(BuildContext context) => AppScope(
    state: state,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CUPRA Instant Drive · Demo',
      theme: buildAppTheme(),
      home: AnimatedBuilder(
        animation: state,
        builder: (context, _) =>
            state.initialized ? const LandingScreen() : const _BootScreen(),
      ),
    ),
  );
}

class _BootScreen extends StatelessWidget {
  const _BootScreen();
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.copper),
          SizedBox(height: 20),
          Text(
            'DEMO WIRD VORBEREITET',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    ),
  );
}
