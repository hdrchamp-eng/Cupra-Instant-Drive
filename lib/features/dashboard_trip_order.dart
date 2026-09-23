import 'dart:async';

import 'package:flutter/material.dart';

import '../core/widgets/price_editor_dialog.dart';

import '../app/app.dart';
import '../app/router.dart';
import '../core/data/demo_seed.dart';
import '../core/design/app_theme.dart';
import '../core/widgets/vehicle_photo.dart';
import '../core/models/models.dart';
import '../core/services/export_service.dart';
import '../core/utils/booking_logic.dart';
import '../core/widgets/common.dart';
import 'booking_auth.dart';
import 'landing_discovery.dart' show DiscoveryScreen, VehicleCard;

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    if (!state.loggedIn) {
      return _LoggedOut(
        onLogin: () => AppRouter.push(context, const AuthScreen()),
      );
    }
    return PageWidth(
      child: ListView(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hoi ${state.profile?.firstName ?? ''}',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const Text('Alles bereit für deinen nächsten Alltagstest.'),
                  ],
                ),
              ),
              StatusPill(
                state.verificationStatus == VerificationStatus.verified
                    ? 'VERIFIZIERT'
                    : 'PRÜFUNG OFFEN',
                color: state.verificationStatus == VerificationStatus.verified
                    ? AppColors.success
                    : AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 22),
          if (state.bookings.isEmpty)
            _NoBooking(
              onExplore: () => AppRouter.push(context, const DiscoveryScreen()),
            )
          else ...[
            const SectionTitle('Nächste Probefahrt', kicker: 'Deine Buchung'),
            const SizedBox(height: 12),
            _UpcomingBooking(booking: state.bookings.first),
            const SizedBox(height: 28),
          ],
          const SectionTitle(
            'Buchungsverlauf',
            kicker: 'Vergangen & storniert',
          ),
          const SizedBox(height: 12),
          if (state.bookings.length < 2)
            const _EmptyHistory()
          else
            ...state.bookings
                .skip(1)
                .map(
                  (b) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      child: Icon(Icons.directions_car),
                    ),
                    title: Text(b.reference),
                    subtitle: Text(b.status.name),
                    trailing: Text(chf(b.priceRappen)),
                  ),
                ),
          const SizedBox(height: 26),
          const SectionTitle('Schnellzugriff'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: () => showInfoDialog(
                  context,
                  'Support',
                  'Demo-Support: +41 44 555 24 24\nNotfall: Lokale Rettungsdienste über 112.',
                ),
                icon: const Icon(Icons.support_agent),
                label: const Text('Support & Notfall'),
              ),
              OutlinedButton.icon(
                onPressed: () => showInfoDialog(
                  context,
                  'Versicherung',
                  'Versicherungsbedingungen sind Platzhalter. Selbstbehalt in der Demo: CHF 1’500.',
                ),
                icon: const Icon(Icons.shield_outlined),
                label: const Text('Versicherung'),
              ),
              OutlinedButton.icon(
                onPressed: () => showInfoDialog(
                  context,
                  'Benachrichtigungen',
                  'Erinnerung 24 h und 30 min vor der Fahrt aktiviert.',
                ),
                icon: const Icon(Icons.notifications_outlined),
                label: const Text('Erinnerungen'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoggedOut extends StatelessWidget {
  const _LoggedOut({required this.onLogin});
  final VoidCallback onLogin;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline, size: 48, color: AppColors.copper),
          const SizedBox(height: 14),
          Text(
            'Deine Fahrten sind geschützt',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 7),
          const Text('Melde dich im sicheren Demo-Modus an.'),
          const SizedBox(height: 18),
          FilledButton(onPressed: onLogin, child: const Text('Anmelden')),
        ],
      ),
    ),
  );
}

class _NoBooking extends StatelessWidget {
  const _NoBooking({required this.onExplore});
  final VoidCallback onExplore;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          const Icon(
            Icons.calendar_month_outlined,
            size: 42,
            color: AppColors.copper,
          ),
          const SizedBox(height: 12),
          Text(
            'Noch keine Probefahrt',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 5),
          const Text('Buche eine kostenlose 60-Minuten-Demo.'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onExplore,
            child: const Text('Fahrzeug finden'),
          ),
        ],
      ),
    ),
  );
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();
  @override
  Widget build(BuildContext context) => const Card(
    child: Padding(
      padding: EdgeInsets.all(18),
      child: Row(
        children: [
          Icon(Icons.history, color: AppColors.muted),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Abgeschlossene und stornierte Fahrten erscheinen hier.',
            ),
          ),
        ],
      ),
    ),
  );
}

class _UpcomingBooking extends StatelessWidget {
  const _UpcomingBooking({required this.booking});
  final Booking booking;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final vehicle = state.vehicleById(booking.vehicleId);
    final hub = state.hubById(booking.hubId);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: 180,
            width: double.infinity,
            child: VehiclePhoto(vehicle.imageAsset, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${vehicle.model} ${vehicle.variant}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    StatusPill(booking.status.name.toUpperCase()),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  '${hub.name} · ${booking.start.day}.${booking.start.month}.${booking.start.year} um ${booking.start.hour.toString().padLeft(2, '0')}:${booking.start.minute.toString().padLeft(2, '0')}',
                ),
                const SizedBox(height: 12),
                const _Countdown(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: booking.status == BookingStatus.cancelled
                            ? null
                            : () => AppRouter.push(
                                context,
                                const TripFlowScreen(),
                              ),
                        icon: const Icon(Icons.key),
                        label: const Text('Check-in starten'),
                      ),
                    ),
                    const SizedBox(width: 9),
                    IconButton.filledTonal(
                      tooltip: 'Buchung stornieren',
                      onPressed: booking.status == BookingStatus.cancelled
                          ? null
                          : () => _confirmCancel(context, state),
                      icon: const Icon(Icons.cancel_outlined),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context, dynamic state) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Buchung stornieren?'),
        content: const Text('In dieser Demo ist die Stornierung kostenfrei.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Behalten'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Stornieren'),
          ),
        ],
      ),
    );
    if (ok == true) state.cancelBooking(booking.id);
  }
}

class _Countdown extends StatefulWidget {
  const _Countdown();
  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown> {
  late Timer timer;
  int seconds = 7540;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => seconds--);
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule, color: AppColors.copper),
          const SizedBox(width: 9),
          const Text('Check-in öffnet in'),
          const Spacer(),
          Text(
            '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class TripFlowScreen extends StatefulWidget {
  const TripFlowScreen({super.key});
  @override
  State<TripFlowScreen> createState() => _TripFlowScreenState();
}

class _TripFlowScreenState extends State<TripFlowScreen> {
  bool damage = false;
  bool returnChecks = false;
  bool simulateWindow = false;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final stage = state.tripStage;
    final booking = state.bookings.isNotEmpty ? state.bookings.first : null;
    final vehicle = booking == null
        ? demoVehicles.first
        : state.vehicleById(booking.vehicleId);
    final checkInAllowed =
        booking == null || isWithinCheckInWindow(booking) || simulateWindow;
    return Scaffold(
      appBar: AppBar(title: const Text('Fahrt-Sandbox')),
      body: PageWidth(
        child: ListView(
          children: [
            const DemoNotice(
              text: 'Sandbox: Standort, Licht/Hupe, Entriegelung und Fahrzeugzustand werden nur simuliert.',
            ),
            const SizedBox(height: 18),
            _TripHeader(vehicle: vehicle, stage: stage),
            const SizedBox(height: 18),
            if (stage == TripStage.upcoming && booking != null) ...[
              DemoNotice(
                text: isWithinCheckInWindow(booking)
                    ? 'Das Check-in-Zeitfenster ist geöffnet.'
                    : 'Check-in öffnet 15 Minuten vor dem gebuchten Start. Für die Vorführung kann das Demo-Zeitfenster simuliert werden.',
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: simulateWindow,
                onChanged: (value) => setState(() => simulateWindow = value),
                title: const Text('Demo-Zeitfenster simulieren'),
                subtitle: const Text(
                  'Nur lokal · keine echte Fahrzeugfreigabe',
                ),
              ),
            ],
            ...TripStage.values
                .where((s) => s != TripStage.upcoming)
                .map((s) => _StageRow(stage: s, current: stage)),
            const SizedBox(height: 20),
            if (stage == TripStage.locationChecked)
              CheckboxListTile(
                value: damage,
                onChanged: (v) => setState(() => damage = v ?? false),
                title: const Text('Fahrzeug rundum geprüft'),
                subtitle: const Text(
                  'Keine neuen Schäden erkannt · optionales Demo-Foto übersprungen',
                ),
              ),
            if (stage == TripStage.damageChecked)
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Licht blinkt · Simulation'),
                      ),
                    ),
                    icon: const Icon(Icons.lightbulb_outline),
                    label: const Text('Licht blinken'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Hupe ertönt · Simulation')),
                    ),
                    icon: const Icon(Icons.campaign_outlined),
                    label: const Text('Hupe'),
                  ),
                ],
              ),
            if (stage == TripStage.unlocked) const _SafetyIntro(),
            if (stage == TripStage.active) const _ActiveTrip(),
            if (stage == TripStage.returning)
              CheckboxListTile(
                value: returnChecks,
                onChanged: (v) => setState(() => returnChecks = v ?? false),
                title: const Text('Rückgabe vollständig geprüft'),
                subtitle: const Text(
                  'Hub korrekt · 64 % Ladestand · keine Gegenstände · verriegelt',
                ),
              ),
            if (stage == TripStage.completed)
              _TripComplete(
                onOffer: () =>
                    AppRouter.push(context, OfferScreen(vehicle: vehicle)),
              ),
            if (stage != TripStage.completed) ...[
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed:
                    (!checkInAllowed && stage == TripStage.upcoming) ||
                        (stage == TripStage.locationChecked && !damage) ||
                        (stage == TripStage.returning && !returnChecks)
                    ? null
                    : state.advanceTrip,
                icon: Icon(_stageIcon(stage)),
                label: Text(_action(stage)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static IconData _stageIcon(TripStage s) => switch (s) {
    TripStage.upcoming => Icons.location_searching,
    TripStage.locationChecked => Icons.fact_check_outlined,
    TripStage.damageChecked => Icons.lock_open,
    TripStage.unlocked => Icons.play_arrow,
    TripStage.active => Icons.keyboard_return,
    TripStage.returning => Icons.lock,
    TripStage.completed => Icons.check,
  };
  static String _action(TripStage s) => switch (s) {
    TripStage.upcoming => 'Demo-Standort bestätigen',
    TripStage.locationChecked => 'Fahrzeugcheck bestätigen',
    TripStage.damageChecked => 'Fahrzeug entriegeln · Simulation',
    TripStage.unlocked => '30-Sekunden-Onboarding abschliessen',
    TripStage.active => 'Rückgabe starten',
    TripStage.returning => 'Rückgabe abschliessen',
    TripStage.completed => 'Abgeschlossen',
  };
}

class _TripHeader extends StatelessWidget {
  const _TripHeader({required this.vehicle, required this.stage});
  final Vehicle vehicle;
  final TripStage stage;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.surfaceHigh,
            child: Icon(Icons.directions_car, color: AppColors.copper),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${vehicle.model} ${vehicle.variant}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text('ZH 824 193 · ${stage.name}'),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _StageRow extends StatelessWidget {
  const _StageRow({required this.stage, required this.current});
  final TripStage stage;
  final TripStage current;
  @override
  Widget build(BuildContext context) {
    final done = stage.index <= current.index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: done ? AppColors.success : AppColors.line,
          ),
          const SizedBox(width: 10),
          Text(
            _label(stage),
            style: TextStyle(
              color: done ? AppColors.cream : AppColors.muted,
              fontWeight: done ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  static String _label(TripStage s) => switch (s) {
    TripStage.upcoming => 'Buchung bereit',
    TripStage.locationChecked => 'Standort bestätigt',
    TripStage.damageChecked => 'Fahrzeugzustand dokumentiert',
    TripStage.unlocked => 'Keyless entriegelt',
    TripStage.active => 'Fahrt aktiv',
    TripStage.returning => 'Rückgabeprüfung',
    TripStage.completed => 'Fahrt abgeschlossen',
  };
}

class _SafetyIntro extends StatelessWidget {
  const _SafetyIntro();
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '30-Sekunden-Einführung',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.battery_charging_full, color: AppColors.copper),
            title: Text('Start & Rekuperation'),
            subtitle: Text(
              'Bremse drücken, Starttaste und Fahrstufe D wählen.',
            ),
          ),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.touch_app, color: AppColors.copper),
            title: Text('Assistenzsysteme'),
            subtitle: Text('Alle Systeme sind nur erklärende Demo-Inhalte.'),
          ),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.sos, color: AppColors.copper),
            title: Text('Hilfe'),
            subtitle: Text('Bei echten Notfällen immer 112 wählen.'),
          ),
        ],
      ),
    ),
  );
}

class _ActiveTrip extends StatelessWidget {
  const _ActiveTrip();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF8B173C), AppColors.surfaceHigh],
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [
        const Text(
          'VERBLEIBENDE ZEIT',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text('48:23', style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => showInfoDialog(
                  context,
                  'Hilfe während der Fahrt',
                  'Demo-Support: +41 44 555 24 24\nIm Notfall 112.',
                ),
                icon: const Icon(Icons.support_agent),
                label: const Text('Hilfe'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => showInfoDialog(
                  context,
                  'Verlängerung',
                  '30 Minuten Verlängerung für CHF 19.00 als Sandbox vorgemerkt.',
                ),
                icon: const Icon(Icons.more_time),
                label: const Text('Verlängern'),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _TripComplete extends StatelessWidget {
  const _TripComplete({required this.onOffer});
  final VoidCallback onOffer;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Icon(Icons.flag_circle, size: 68, color: AppColors.success),
      const SizedBox(height: 12),
      Text(
        'Fahrt erfolgreich beendet',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 5),
      const Text('64 % Ladestand · 42 km · Fahrzeug verriegelt'),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: onOffer,
          child: const Text('Fahrzeug konfigurieren & Angebot erhalten'),
        ),
      ),
    ],
  );
}

class OfferScreen extends StatefulWidget {
  const OfferScreen({required this.vehicle, super.key});
  final Vehicle vehicle;
  @override
  State<OfferScreen> createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {
  FinanceMode mode = FinanceMode.leasing;
  String colour = 'Graphite';
  int term = 48;
  bool insurance = true;
  bool tradeIn = false;
  double nps = 8;
  bool submittedFeedback = false;
  int get monthly => switch (mode) {
    FinanceMode.purchase => 5690000,
    FinanceMode.leasing => 64900,
    FinanceMode.subscription => 109900,
  };
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Dein Angebot')),
    body: PageWidth(
      child: ListView(
        children: [
          Text(
            'Passt der ${widget.vehicle.model} zu dir?',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 5),
          const Text('Konfiguriere jetzt ein unverbindliches Demo-Angebot.'),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wie war deine Fahrt?',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Slider(
                    value: nps,
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: nps.round().toString(),
                    onChanged: (v) => setState(() => nps = v),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Unwahrscheinlich',
                        style: TextStyle(fontSize: 11),
                      ),
                      const Spacer(),
                      Text(
                        'NPS ${nps.round()}',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const Spacer(),
                      const Text(
                        'Sehr wahrscheinlich',
                        style: TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: submittedFeedback
                        ? null
                        : () => setState(() => submittedFeedback = true),
                    child: Text(
                      submittedFeedback
                          ? 'Feedback gespeichert'
                          : 'Feedback senden',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          const SectionTitle('Finanzierung', kicker: 'Kauf · Leasing · Abo'),
          const SizedBox(height: 12),
          SegmentedButton<FinanceMode>(
            segments: const [
              ButtonSegment(value: FinanceMode.purchase, label: Text('Kauf')),
              ButtonSegment(value: FinanceMode.leasing, label: Text('Leasing')),
              ButtonSegment(
                value: FinanceMode.subscription,
                label: Text('Abo'),
              ),
            ],
            selected: {mode},
            onSelectionChanged: (v) => setState(() => mode = v.first),
          ),
          const SizedBox(height: 22),
          const Text('Farbe', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Graphite', 'Dark Blue', 'Copper Grey']
                .map(
                  (c) => ChoiceChip(
                    label: Text(c),
                    selected: colour == c,
                    onSelected: (_) => setState(() => colour = c),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          if (mode != FinanceMode.purchase) ...[
            Text(
              'Laufzeit: $term Monate',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            Slider(
              value: term.toDouble(),
              min: 24,
              max: 60,
              divisions: 3,
              label: '$term',
              onChanged: (v) => setState(() => term = v.round()),
            ),
          ],
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: insurance,
            onChanged: (v) => setState(() => insurance = v),
            title: const Text('Zurich Markenversicherung · Demo'),
            subtitle: const Text('+ CHF 118/Monat · kein Versicherungsvertrag'),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: tradeIn,
            onChanged: (v) => setState(() => tradeIn = v),
            title: const Text('Trade-in-Schätzung'),
            subtitle: Text(
              tradeIn
                  ? 'Unverbindliche Demo-Schätzung: CHF 18’400'
                  : 'Vorhandenes Fahrzeug optional schätzen',
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.copper),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    mode == FinanceMode.purchase
                        ? 'Einmalpreis'
                        : 'Ab pro Monat',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ),
                Text(
                  mode == FinanceMode.purchase
                      ? chf(monthly)
                      : chf(monthly + (insurance ? 11800 : 0)),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () => _review(context),
            child: const Text('Unverbindliche Bestellung prüfen'),
          ),
          const SizedBox(height: 30),
        ],
      ),
    ),
  );
  Future<void> _review(BuildContext context) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Bestellung prüfen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.vehicle.model} ${widget.vehicle.variant}'),
            Text('$colour · ${mode.name}'),
            Text(
              mode == FinanceMode.purchase
                  ? chf(monthly)
                  : '${chf(monthly + (insurance ? 11800 : 0))} / Monat',
            ),
            const SizedBox(height: 12),
            const Text(
              'Dies ist unverbindlich und löst keinen Vertrag oder eine Zahlung aus.',
              style: TextStyle(color: AppColors.copper),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Ändern'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Demo-Bestellung senden'),
          ),
        ],
      ),
    );
    if (accepted == true && context.mounted) {
      final order = AppScope.of(context).createOrder(
        vehicle: widget.vehicle,
        mode: mode,
        colour: colour,
        termMonths: term,
        insurance: insurance,
        tradeIn: tradeIn,
      );
      AppRouter.replace(context, OrderConfirmationScreen(order: order));
    }
  }
}

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({required this.order, super.key});
  final VehicleOrder order;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final vehicle = state.vehicleById(order.vehicleId);
    final profile = state.profile;
    return Scaffold(
      appBar: AppBar(title: const BrandMark(compact: true)),
      body: PageWidth(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: ListView(
              children: [
                const Icon(Icons.task_alt, size: 72, color: AppColors.success),
                const SizedBox(height: 12),
                Text(
                  'Demo-Bestellung bestätigt',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text(
                  order.reference,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.copper,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 22),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _OrderRow(
                          'Fahrzeug',
                          '${vehicle.model} ${vehicle.variant}',
                        ),
                        _OrderRow(
                          'Bestelldatum',
                          '${order.createdAt.day}.${order.createdAt.month}.${order.createdAt.year}',
                        ),
                        _OrderRow(
                          'Kundin/Kunde',
                          profile == null
                              ? 'Synthetisches Demo-Profil'
                              : '${profile.firstName} ${profile.lastName}',
                        ),
                        _OrderRow(
                          'Lieferadresse',
                          profile?.address ?? 'Demo-Hub Zürich',
                        ),
                        _OrderRow('Farbe', order.colour),
                        _OrderRow('Finanzierung', order.mode.name),
                        _OrderRow('Laufzeit', '${order.termMonths} Monate'),
                        _OrderRow(
                          'Versicherung',
                          order.insurance ? 'Demo ausgewählt' : 'Nein',
                        ),
                        _OrderRow(
                          'Trade-in',
                          order.tradeIn ? 'Demo-Schätzung vorgemerkt' : 'Nein',
                        ),
                        _OrderRow(
                          'Preis',
                          chf(order.totalRappen),
                          strong: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const DemoNotice(
                  text: 'Dies ist eine unverbindliche Demo-Bestätigung und kein Kauf-, Leasing-, Versicherungs- oder Kreditvertrag.',
                ),
                const SizedBox(height: 14),
                const Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.next_plan_outlined,
                      color: AppColors.copper,
                    ),
                    title: Text('Nächste Schritte'),
                    subtitle: Text(
                      'In einer echten Lösung würde nun eine Beratung die Konfiguration prüfen. In dieser Demo erfolgt keine Kontaktaufnahme.',
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                  child: const Text('Zur Startseite'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    final text =
                        'Unverbindliche Demo-Bestätigung\n\n'
                        'Bestellung: ${order.reference}\n'
                        'Datum: ${order.createdAt.day}.${order.createdAt.month}.${order.createdAt.year}\n'
                        'Fahrzeug: ${vehicle.model} ${vehicle.variant}\n'
                        'Farbe: ${order.colour}\n'
                        'Finanzierung: ${order.mode.name}\n'
                        'Laufzeit: ${order.termMonths} Monate\n'
                        'Versicherung: ${order.insurance ? 'Demo ausgewählt' : 'Nein'}\n'
                        'Trade-in: ${order.tradeIn ? 'Demo-Schätzung vorgemerkt' : 'Nein'}\n'
                        'Preis: ${chf(order.totalRappen)}\n\n'
                        'Dies ist kein Kauf-, Leasing-, Versicherungs- oder Kreditvertrag.';
                    downloadTextFile(
                      filename: '${order.reference}.txt',
                      content: text,
                    );
                    if (!printCurrentPage()) {
                      showInfoDialog(context, 'Druckbare Bestätigung', text);
                    }
                  },
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Bestätigung drucken / PDF'),
                ),
                OutlinedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Lokale E-Mail-Vorschau geöffnet. Keine Nachricht versendet.',
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.mail_outline),
                  label: const Text('E-Mail-Vorschau'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow(this.label, this.value, {this.strong = false});
  final String label, value;
  final bool strong;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
              color: AppColors.cream,
            ),
          ),
        ),
      ],
    ),
  );
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool push = true;
  bool email = false;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    if (!state.loggedIn) {
      return _LoggedOut(
        onLogin: () => AppRouter.push(context, const AuthScreen()),
      );
    }
    final profile = state.profile!;
    final favorites = demoVehicles
        .where((v) => state.favoriteIds.contains(v.id))
        .toList();
    return PageWidth(
      child: ListView(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.surfaceHigh,
                child: Icon(Icons.person, size: 30, color: AppColors.copper),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${profile.firstName} ${profile.lastName}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(profile.email),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => showInfoDialog(
                  context,
                  'Profil bearbeiten',
                  'Demo-Profilwerte bleiben lokal und enthalten nur synthetische Daten.',
                ),
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const DemoNotice(
            text: 'Demo-Profil · keine echten Personen- oder Dokumentdaten verwenden',
          ),
          const SizedBox(height: 22),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.verified_user_outlined),
                  title: const Text('Fahrer-Verifizierung'),
                  subtitle: Text(
                    state.verificationStatus == VerificationStatus.verified
                        ? 'Erfolgreich verifiziert'
                        : 'Noch nicht abgeschlossen',
                  ),
                  trailing: Icon(
                    state.verificationStatus == VerificationStatus.verified
                        ? Icons.check_circle
                        : Icons.chevron_right,
                    color:
                        state.verificationStatus == VerificationStatus.verified
                        ? AppColors.success
                        : null,
                  ),
                  onTap: state.verificationStatus == VerificationStatus.verified
                      ? null
                      : state.runVerification,
                ),
                ListTile(
                  leading: const Icon(Icons.home_outlined),
                  title: const Text('Adresse'),
                  subtitle: Text(profile.address),
                ),
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text('Mobilnummer'),
                  subtitle: Text(profile.mobile),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionTitle('Favoriten'),
          const SizedBox(height: 10),
          if (favorites.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  'Markiere Fahrzeuge mit dem Herz, um sie hier zu speichern.',
                ),
              ),
            )
          else
            ...favorites.map(
              (v) => SizedBox(
                height: 250,
                child: VehicleCard(
                  vehicle: v,
                  onTap: () =>
                      AppRouter.push(context, VehicleDetailScreen(vehicle: v)),
                ),
              ),
            ),
          const SizedBox(height: 22),
          const SectionTitle('Benachrichtigungen'),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: push,
            onChanged: (v) => setState(() => push = v),
            title: const Text('Push-Erinnerungen'),
            subtitle: const Text('24 h und 30 min vor der Fahrt'),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: email,
            onChanged: (v) => setState(() => email = v),
            title: const Text('E-Mail-Vorschau'),
            subtitle: const Text('Nur lokales Demo-Log'),
          ),
          const Divider(height: 28),
          OutlinedButton.icon(
            onPressed: () => showInfoDialog(
              context,
              'Datenschutz & Auskunft',
              'Demo-Hinweis: minimale Datenerhebung. In einem Produktivsystem wären Auskunft und Löschung über den Datenschutzkontakt möglich.',
            ),
            icon: const Icon(Icons.privacy_tip_outlined),
            label: const Text('Datenschutz, Auskunft & Löschung'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: state.logout,
            icon: const Icon(Icons.logout),
            label: const Text('Demo abmelden'),
          ),
        ],
      ),
    );
  }
}

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late final List<Vehicle> vehicles = List.of(demoVehicles);
  late final List<Hub> hubs = List.of(demoHubs);
  final Map<String, VehicleStatus> statuses = {
    for (final v in demoVehicles) v.id: v.status,
  };
  final Map<String, int> availabilityCounts = {
    for (final vehicle in demoVehicles) vehicle.id: 3,
  };
  final Map<DrivePackage, int> prices = {
    DrivePackage.standard60: 0,
    DrivePackage.extended90: 2900,
    DrivePackage.weekend: 7900,
  };

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    if (!state.isAdmin) {
      return const Center(child: Text('Adminrolle erforderlich'));
    }
    return PageWidth(
      child: ListView(
        children: [
          Text('Demo-Admin', style: Theme.of(context).textTheme.headlineLarge),
          const Text(
            'Lokale Sandbox-Daten · Statusänderungen sind nicht produktiv.',
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, c) {
              final cols = c.maxWidth > 780 ? 4 : 2;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: cols,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.35,
                children: const [
                  _Kpi('BUCHUNGEN', '128', '+14 %'),
                  _Kpi('AUSLASTUNG', '68 %', 'Pilotflotte'),
                  _Kpi('CONVERSION', '7.4 %', 'Ziel 5–10 %'),
                  _Kpi('NPS', '62', 'CSAT 4.6'),
                ],
              );
            },
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              const Expanded(
                child: SectionTitle('Flotte & Status', kicker: 'CRUD-Demo'),
              ),
              FilledButton.tonalIcon(
                onPressed: _addVehicle,
                icon: const Icon(Icons.add),
                label: const Text('Fahrzeug'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...vehicles.map(
            (v) => Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.directions_car)),
                title: Text('${v.model} ${v.variant}'),
                subtitle: Text(
                  demoHubs.firstWhere((h) => h.id == v.hubId).name,
                ),
                trailing: PopupMenuButton<String>(
                  tooltip: 'Fahrzeug bearbeiten',
                  itemBuilder: (_) => [
                    for (final status in VehicleStatus.values)
                      PopupMenuItem(
                        value: 'status:${status.name}',
                        child: Text('Status: ${status.name}'),
                      ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Fahrzeug löschen'),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'delete') {
                      setState(() {
                        vehicles.removeWhere((item) => item.id == v.id);
                        statuses.remove(v.id);
                        availabilityCounts.remove(v.id);
                      });
                      state.audit.add(
                        AuditEvent(
                          'Admin: Fahrzeug ${v.id} gelöscht',
                          DateTime.now(),
                        ),
                      );
                      return;
                    }
                    final statusName = value.split(':').last;
                    setState(
                      () => statuses[v.id] = VehicleStatus.values.byName(
                        statusName,
                      ),
                    );
                    state.audit.add(
                      AuditEvent(
                        'Admin: ${v.id} → $statusName',
                        DateTime.now(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(
                child: SectionTitle('Hubs', kicker: 'Lokales CRUD'),
              ),
              FilledButton.tonalIcon(
                onPressed: _addHub,
                icon: const Icon(Icons.add_location_alt_outlined),
                label: const Text('Hub'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...hubs.map(
            (hub) => Card(
              child: ListTile(
                leading: const Icon(Icons.location_on_outlined),
                title: Text(hub.name),
                subtitle: Text('${hub.address}\n${hub.hours}'),
                isThreeLine: true,
                trailing: PopupMenuButton<String>(
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('Öffnungszeiten bearbeiten'),
                    ),
                    PopupMenuItem(value: 'delete', child: Text('Hub löschen')),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editHub(hub);
                    } else {
                      _deleteHub(hub);
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SectionTitle(
            'Verfügbarkeiten & Preise',
            kicker: 'Sandbox-Konfiguration',
          ),
          const SizedBox(height: 8),
          ...vehicles
              .take(4)
              .map(
                (vehicle) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${vehicle.model} ${vehicle.variant}'),
                  subtitle: Text(
                    '${availabilityCounts[vehicle.id] ?? 0} aktive Zeitfenster',
                  ),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        tooltip: 'Zeitfenster entfernen',
                        onPressed: (availabilityCounts[vehicle.id] ?? 0) == 0
                            ? null
                            : () => setState(
                                () => availabilityCounts[vehicle.id] =
                                    (availabilityCounts[vehicle.id] ?? 1) - 1,
                              ),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      IconButton(
                        tooltip: 'Zeitfenster hinzufügen',
                        onPressed: () => setState(
                          () => availabilityCounts[vehicle.id] =
                              (availabilityCounts[vehicle.id] ?? 0) + 1,
                        ),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ),
              ),
          ...DrivePackage.values.map(
            (drivePackage) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.payments_outlined),
              title: Text(_packageName(drivePackage)),
              subtitle: Text(chf(prices[drivePackage] ?? 0)),
              trailing: IconButton(
                tooltip: 'Preis bearbeiten',
                onPressed: () => _editPrice(drivePackage),
                icon: const Icon(Icons.edit_outlined),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: SectionTitle(
                  'Buchungen & Bestellungen',
                  kicker: 'Statusverwaltung',
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _csv(context),
                icon: const Icon(Icons.download),
                label: const Text('CSV-Export'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (state.bookings.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text('Noch keine Demo-Buchungen.'),
              ),
            )
          else
            ...state.bookings.map(
              (b) => ListTile(
                leading: const Icon(Icons.confirmation_number_outlined),
                title: Text(b.reference),
                subtitle: Text('${b.status.name} · ${chf(b.priceRappen)}'),
                trailing: PopupMenuButton<String>(
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'audit',
                      child: Text('Audit anzeigen'),
                    ),
                    PopupMenuItem(value: 'cancel', child: Text('Stornieren')),
                    PopupMenuItem(
                      value: 'complete',
                      child: Text('Als abgeschlossen markieren'),
                    ),
                    PopupMenuItem(value: 'delete', child: Text('Löschen')),
                  ],
                  onSelected: (value) {
                    if (value == 'cancel') {
                      state.cancelBooking(b.id);
                    } else if (value == 'complete') {
                      state.adminSetBookingStatus(
                        b.id,
                        BookingStatus.completed,
                      );
                    } else if (value == 'delete') {
                      state.adminDeleteBooking(b.id);
                    } else {
                      showInfoDialog(
                        context,
                        'Audit-Historie',
                        'Buchung erstellt → Zahlung simuliert → bestätigt',
                      );
                    }
                  },
                ),
              ),
            ),
          const SizedBox(height: 20),
          const SectionTitle('Audit-Historie'),
          const SizedBox(height: 8),
          ...state.audit.reversed
              .take(8)
              .map(
                (e) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: const Icon(Icons.history, size: 18),
                  title: Text(e.action),
                  trailing: Text(
                    '${e.createdAt.hour.toString().padLeft(2, '0')}:${e.createdAt.minute.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
        ],
      ),
    );
  }

  void _addVehicle() {
    final i = vehicles.length + 1;
    final v = Vehicle(
      id: 'admin-$i',
      model: 'Demo Concept',
      variant: 'Fleet $i',
      powertrain: 'Elektro',
      power: '250 PS',
      range: '480 km',
      seats: 5,
      hubId: 'hub-zrh-hb',
      status: VehicleStatus.offline,
      accent: 0xFFC47B57,
      features: const ['Admin Seed'],
    );
    setState(() {
      vehicles.add(v);
      statuses[v.id] = v.status;
      availabilityCounts[v.id] = 0;
    });
  }

  void _addHub() {
    final number = hubs.length + 1;
    setState(() {
      hubs.add(
        Hub(
          id: 'admin-hub-$number',
          name: 'Demo Hub $number',
          city: 'Zürich',
          address: 'Demo-Adresse $number, 8000 Zürich',
          distanceKm: 4.5 + number,
          latitude: 47.3769,
          longitude: 8.5417,
          hours: '08:00–20:00',
          parkingNote: 'Lokal im Adminbereich erzeugt',
        ),
      );
    });
  }

  void _editHub(Hub hub) {
    final index = hubs.indexWhere((item) => item.id == hub.id);
    if (index < 0) return;
    setState(() {
      hubs[index] = Hub(
        id: hub.id,
        name: hub.name,
        city: hub.city,
        address: hub.address,
        distanceKm: hub.distanceKm,
        latitude: hub.latitude,
        longitude: hub.longitude,
        hours: hub.hours.contains('bearbeitet')
            ? '08:00–20:00'
            : '06:00–23:00 · bearbeitet',
        parkingNote: hub.parkingNote,
      );
    });
  }

  void _deleteHub(Hub hub) {
    final inUse = vehicles.any((vehicle) => vehicle.hubId == hub.id);
    if (inUse) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Hub kann nicht gelöscht werden: Fahrzeuge sind zugeordnet.',
          ),
        ),
      );
      return;
    }
    setState(() => hubs.removeWhere((item) => item.id == hub.id));
  }

  Future<void> _editPrice(DrivePackage drivePackage) async {
    final value = await showDialog<int>(
      context: context,
      builder: (_) => PriceEditorDialog(
        title: '${_packageName(drivePackage)} bearbeiten',
        initialRappen: prices[drivePackage] ?? 0,
      ),
    );
    if (value != null && mounted) {
      setState(() => prices[drivePackage] = value);
    }
  }

  static String _packageName(DrivePackage value) => switch (value) {
    DrivePackage.standard60 => '60 Minuten Standard',
    DrivePackage.extended90 => '90 Minuten Extended',
    DrivePackage.weekend => 'Wochenende Premium',
  };

  void _csv(BuildContext context) {
    final state = AppScope.of(context);
    final rows = <String>[
      'booking_reference,status,price_chf,vehicle_id,hub_id,start',
      for (final booking in state.bookings)
        [
          booking.reference,
          booking.status.name,
          (booking.priceRappen / 100).toStringAsFixed(2),
          booking.vehicleId,
          booking.hubId,
          booking.start.toIso8601String(),
        ].map(csvCell).join(','),
    ];
    if (state.bookings.isEmpty) {
      rows.add(
        [
          'CID-DEMO',
          'confirmed',
          '0.00',
          'veh-01',
          'hub-zrh-hb',
          '',
        ].map(csvCell).join(','),
      );
    }
    final content = '${rows.join('\n')}\n';
    final downloaded = downloadTextFile(
      filename: 'instant-drive-bookings.csv',
      content: content,
      mimeType: 'text/csv;charset=utf-8',
    );
    if (!downloaded) {
      showInfoDialog(context, 'CSV-Export · lokale Vorschau', content);
    }
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi(this.label, this.value, this.note);
  final String label, value, note;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.muted,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          Text(
            note,
            style: const TextStyle(fontSize: 11, color: AppColors.success),
          ),
        ],
      ),
    ),
  );
}
