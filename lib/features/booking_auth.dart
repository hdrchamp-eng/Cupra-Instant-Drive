import 'package:flutter/material.dart';

import '../app/app.dart';
import '../app/app_state.dart';
import '../app/router.dart';
import '../core/data/demo_seed.dart';
import '../core/design/app_theme.dart';
import '../core/widgets/vehicle_photo.dart';
import '../core/models/models.dart';
import '../core/services/export_service.dart';
import '../core/services/sandbox_adapters.dart';
import '../core/utils/booking_logic.dart';
import '../core/widgets/common.dart';
import 'landing_discovery.dart' show MainShell;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.initialTab = 0});

  final int initialTab;
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController tabs = TabController(
    length: 2,
    vsync: this,
    initialIndex: widget.initialTab == 1 ? 1 : 0,
  );
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController(text: 'nina@demo.ch');
  final password = TextEditingController(text: 'demo1234');
  final firstName = TextEditingController(text: 'Nina');
  final lastName = TextEditingController(text: 'Muster');
  final mobile = TextEditingController(text: '+41 79 555 01 24');
  final address = TextEditingController(text: 'Lagerstrasse 18, 8004 Zürich');
  DateTime birthDate = DateTime(1993, 6, 18);
  bool terms = false;
  bool privacy = false;
  bool loading = false;
  @override
  void dispose() {
    tabs.dispose();
    email.dispose();
    password.dispose();
    firstName.dispose();
    lastName.dispose();
    mobile.dispose();
    address.dispose();
    super.dispose();
  }

  Future<void> login({bool admin = false}) async {
    setState(() => loading = true);
    await AppScope.of(context).demoLogin(admin: admin);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> register() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (!terms || !privacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte AGB und Datenschutz separat bestätigen.'),
        ),
      );
      return;
    }
    setState(() => loading = true);
    await AppScope.of(context).register(
      UserProfile(
        firstName: firstName.text,
        lastName: lastName.text,
        email: email.text,
        mobile: mobile.text,
        address: address.text,
        birthDate: birthDate,
      ),
    );
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const BrandMark(compact: true)),
    body: PageWidth(
      child: ListView(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Willkommen bei Instant Drive',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Nutze ausschliesslich synthetische Demo-Daten.',
                      ),
                      const SizedBox(height: 18),
                      const DemoNotice(),
                      const SizedBox(height: 18),
                      TabBar(
                        controller: tabs,
                        tabs: const [
                          Tab(text: 'Anmelden'),
                          Tab(text: 'Registrieren'),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 430,
                        child: TabBarView(
                          controller: tabs,
                          children: [_loginForm(), _registerForm()],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _loginForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextField(
        controller: email,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: 'E-Mail',
          prefixIcon: Icon(Icons.mail_outline),
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: password,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: 'Passwort',
          prefixIcon: Icon(Icons.lock_outline),
        ),
      ),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () => showInfoDialog(
            context,
            'Passwort zurücksetzen',
            'Demo-Link erzeugt. Es wurde keine echte E-Mail gesendet.',
          ),
          child: const Text('Passwort vergessen?'),
        ),
      ),
      FilledButton(
        onPressed: loading ? null : login,
        child: loading
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Demo-Anmeldung'),
      ),
      const SizedBox(height: 10),
      OutlinedButton.icon(
        onPressed: loading ? null : () => login(admin: true),
        icon: const Icon(Icons.admin_panel_settings_outlined),
        label: const Text('Als Demo-Admin anmelden'),
      ),
      const Spacer(),
      const Text(
        'Demo-Zugang: beliebige synthetische Daten funktionieren. Es findet keine Server-Anmeldung statt.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11, color: AppColors.muted),
      ),
    ],
  );

  Widget _registerForm() => Form(
    key: formKey,
    child: SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: firstName,
                  decoration: const InputDecoration(labelText: 'Vorname'),
                  validator: requiredText,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: lastName,
                  decoration: const InputDecoration(labelText: 'Nachname'),
                  validator: requiredText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: email,
            decoration: const InputDecoration(labelText: 'E-Mail'),
            validator: (v) =>
                v != null && v.contains('@') ? null : 'Gültige E-Mail eingeben',
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: mobile,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Mobilnummer',
              hintText: '+41 79 555 01 24',
            ),
            validator: requiredText,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: address,
            decoration: const InputDecoration(
              labelText: 'Adresse',
              hintText: 'Strasse, PLZ Ort',
            ),
            validator: requiredText,
          ),
          const SizedBox(height: 10),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _selectBirthDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Geburtsdatum',
                prefixIcon: Icon(Icons.cake_outlined),
              ),
              child: Text(
                '${birthDate.day.toString().padLeft(2, '0')}.'
                '${birthDate.month.toString().padLeft(2, '0')}.'
                '${birthDate.year}',
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: password,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Passwort'),
            validator: (v) =>
                (v?.length ?? 0) >= 8 ? null : 'Mindestens 8 Zeichen',
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: terms,
            onChanged: (v) => setState(() => terms = v ?? false),
            title: const Text(
              'AGB akzeptieren (Demo-Platzhalter)',
              style: TextStyle(fontSize: 13),
            ),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: privacy,
            onChanged: (v) => setState(() => privacy = v ?? false),
            title: const Text(
              'Datenschutz akzeptieren',
              style: TextStyle(fontSize: 13),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: register,
              child: const Text('Demo-Konto erstellen'),
            ),
          ),
        ],
      ),
    ),
  );
  static String? requiredText(String? v) =>
      (v?.trim().isEmpty ?? true) ? 'Pflichtfeld' : null;

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: birthDate,
      firstDate: DateTime(1940),
      lastDate: DateTime(now.year - 21, now.month, now.day),
      helpText: 'Geburtsdatum wählen',
    );
    if (selected != null && mounted) {
      setState(() => birthDate = selected);
    }
  }
}

class VehicleDetailScreen extends StatefulWidget {
  const VehicleDetailScreen({required this.vehicle, super.key});
  final Vehicle vehicle;
  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  late AvailabilitySlot selected = demoSlotsFor(widget.vehicle.id).first;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final hub = state.hubById(widget.vehicle.hubId);
    final slots = demoSlotsFor(widget.vehicle.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehicle.model),
        actions: [
          IconButton(
            onPressed: () => state.toggleFavorite(widget.vehicle.id),
            icon: Icon(
              state.favoriteIds.contains(widget.vehicle.id)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: state.favoriteIds.contains(widget.vehicle.id)
                  ? AppColors.copper
                  : null,
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 330,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Color(widget.vehicle.accent).withValues(alpha: .13),
                    BlendMode.color,
                  ),
                  child: VehiclePhoto(
                    widget.vehicle.imageAsset,
                    fit: BoxFit.cover,
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, AppColors.ink],
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const StatusPill('LIVE-DEMO · VERFÜGBAR'),
                      const SizedBox(height: 10),
                      Text(
                        '${widget.vehicle.model} ${widget.vehicle.variant}',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      Text(
                        '${widget.vehicle.powertrain} · ${widget.vehicle.power}',
                        style: const TextStyle(color: AppColors.cream),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          PageWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, c) => Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _Spec('REICHWEITE', widget.vehicle.range),
                      _Spec('LEISTUNG', widget.vehicle.power),
                      _Spec('SITZPLÄTZE', '${widget.vehicle.seats}'),
                      _Spec('ANTRIEB', widget.vehicle.powertrain),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const SectionTitle('Ausstattung', kicker: 'Demo-Fahrzeug'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.vehicle.features
                      .map(
                        (e) => Chip(
                          avatar: const Icon(
                            Icons.check_circle_outline,
                            size: 17,
                          ),
                          label: Text(e),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 30),
                const SectionTitle('Verfügbare Zeitfenster', kicker: 'Morgen'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: slots.map((s) {
                    final label = '${two(s.start.hour)}:${two(s.start.minute)}';
                    return ChoiceChip(
                      label: Text(label),
                      selected: selected.id == s.id,
                      onSelected: (_) => setState(() => selected = s),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),
                const SectionTitle('Abholung', kicker: 'Zentraler Hub'),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: AppColors.copper,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                hub.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            Text('${hub.distanceKm.toStringAsFixed(1)} km'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(hub.address),
                        Text('${hub.hours} · ${hub.parkingNote}'),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () => showInfoDialog(
                            context,
                            'Wegbeschreibung',
                            'Demo-Route zu ${hub.address}. Es wird keine externe Karten-App geöffnet.',
                          ),
                          icon: const Icon(Icons.directions_outlined),
                          label: const Text('Wegbeschreibung'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                const DemoNotice(),
                const SizedBox(height: 110),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        color: const Color(0xFF0C1423),
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.paddingOf(context).bottom + 12,
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STANDARD 60 MIN',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'CHF 0.00',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    if (!state.loggedIn) {
                      final ok = await AppRouter.push<bool>(
                        context,
                        const AuthScreen(),
                      );
                      if (ok != true || !context.mounted) return;
                    }
                    if (!context.mounted) return;
                    AppRouter.push(
                      context,
                      BookingFlowScreen(
                        vehicle: widget.vehicle,
                        initialSlot: selected,
                      ),
                    );
                  },
                  child: const Text('Probefahrt buchen'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String two(int v) => v.toString().padLeft(2, '0');
}

class _Spec extends StatelessWidget {
  const _Spec(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    width: 160,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: AppColors.muted,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 2,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}

class BookingFlowScreen extends StatefulWidget {
  const BookingFlowScreen({
    required this.vehicle,
    required this.initialSlot,
    super.key,
  });
  final Vehicle vehicle;
  final AvailabilitySlot initialSlot;
  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  int step = 0;
  late DateTime start = widget.initialSlot.start;
  DrivePackage drivePackage = DrivePackage.standard60;
  bool delivery = false;
  bool terms = false;
  bool cancellation = false;
  bool identityDemoSelected = false;
  bool licenceDemoSelected = false;
  bool loading = false;
  int get price => packagePriceRappen(
    drivePackage,
    homeDelivery: delivery,
    performance: widget.vehicle.performance,
  );
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final hub = state.hubById(widget.vehicle.hubId);
    return Scaffold(
      appBar: AppBar(title: const Text('Probefahrt buchen')),
      body: PageWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(
                4,
                (i) => Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: i == 3 ? 0 : 6),
                    decoration: BoxDecoration(
                      color: i <= step ? AppColors.copper : AppColors.line,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Schritt ${step + 1} von 4',
              style: const TextStyle(
                color: AppColors.copper,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: SingleChildScrollView(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: KeyedSubtree(
                    key: ValueKey(step),
                    child: [
                      _bookingAndTime(hub),
                      _package(),
                      _verification(state),
                      _review(state, hub),
                    ][step],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                if (step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => step--),
                      child: const Text('Zurück'),
                    ),
                  ),
                if (step > 0) const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: loading ? null : () => next(state),
                    child: loading
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            step == 3 ? 'Verbindliche Demo-Buchung' : 'Weiter',
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bookingAndTime(Hub hub) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Fahrzeug & Zeit bestätigen',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 16),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 86,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage(widget.vehicle.imageAsset),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.vehicle.model} ${widget.vehicle.variant}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(hub.name),
                    Text(
                      '${start.day}.${start.month}.${start.year} · ${two(start.hour)}:${two(start.minute)} Uhr',
                      style: const TextStyle(color: AppColors.cream),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 18),
      const Text('Alternative Startzeit'),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        children: demoSlotsFor(widget.vehicle.id)
            .map(
              (s) => ChoiceChip(
                label: Text('${two(s.start.hour)}:${two(s.start.minute)}'),
                selected: s.start == start,
                onSelected: (_) => setState(() => start = s.start),
              ),
            )
            .toList(),
      ),
    ],
  );
  Widget _package() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Paket wählen', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 5),
      const Text('Alle Preise inkl. Demo-Gebühren. Keine echte Belastung.'),
      const SizedBox(height: 16),
      ...DrivePackage.values.map(
        (p) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _PackageTile(
            value: p,
            selected: drivePackage == p,
            performance: widget.vehicle.performance,
            onTap: () => setState(() => drivePackage = p),
          ),
        ),
      ),
      const SizedBox(height: 4),
      SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        title: const Text('Haustürlieferung · Demo'),
        subtitle: const Text('+ CHF 39.00 · synthetische Adresse'),
        value: delivery,
        onChanged: (v) => setState(() => delivery = v),
      ),
    ],
  );
  Widget _verification(AppState state) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Fahrerstatus & Bedingungen',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 14),
      const DemoNotice(
        text: 'Keine echten Dokumente hochladen. Der Button nutzt synthetische Prüfdaten.',
      ),
      const SizedBox(height: 14),
      if (state.verificationStatus != VerificationStatus.verified) ...[
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            OutlinedButton.icon(
              onPressed: () => setState(() => identityDemoSelected = true),
              icon: Icon(
                identityDemoSelected
                    ? Icons.check_circle
                    : Icons.badge_outlined,
              ),
              label: Text(
                identityDemoSelected
                    ? 'Demo-ID ausgewählt'
                    : 'Synthetische ID wählen',
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => setState(() => licenceDemoSelected = true),
              icon: Icon(
                licenceDemoSelected
                    ? Icons.check_circle
                    : Icons.document_scanner_outlined,
              ),
              label: Text(
                licenceDemoSelected
                    ? 'Demo-Führerschein gescannt'
                    : 'Demo-Führerschein scannen',
              ),
            ),
            TextButton.icon(
              onPressed: identityDemoSelected && licenceDemoSelected
                  ? () => state.rejectVerification()
                  : null,
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Ablehnung simulieren'),
            ),
          ],
        ),
        const SizedBox(height: 14),
      ],
      Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(
                switch (state.verificationStatus) {
                  VerificationStatus.verified => Icons.verified_user,
                  VerificationStatus.rejected => Icons.gpp_bad_outlined,
                  VerificationStatus.reviewing => Icons.hourglass_top,
                  VerificationStatus.notStarted => Icons.badge_outlined,
                },
                color: switch (state.verificationStatus) {
                  VerificationStatus.verified => AppColors.success,
                  VerificationStatus.rejected => AppColors.error,
                  _ => AppColors.copper,
                },
                size: 34,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(switch (state.verificationStatus) {
                      VerificationStatus.verified =>
                        'Führerschein & ID verifiziert',
                      VerificationStatus.rejected =>
                        'Demo-Verifizierung abgelehnt',
                      VerificationStatus.reviewing => 'Prüfung läuft',
                      VerificationStatus.notStarted =>
                        'Verifizierung ausstehend',
                    }, style: Theme.of(context).textTheme.titleLarge),
                    Text(
                      state.verificationStatus == VerificationStatus.verified
                          ? 'Demo-Prüfung erfolgreich'
                          : state.verificationStatus ==
                                VerificationStatus.rejected
                          ? 'Synthetische Daten erneut auswählen und prüfen'
                          : 'Mindestalter 21 · gültige Fahrerlaubnis erforderlich',
                    ),
                  ],
                ),
              ),
              if (state.verificationStatus != VerificationStatus.verified)
                FilledButton.tonal(
                  onPressed: identityDemoSelected && licenceDemoSelected
                      ? () => state.runVerification()
                      : null,
                  child: const Text('Demo prüfen'),
                ),
            ],
          ),
        ),
      ),
      CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        value: terms,
        onChanged: (v) => setState(() => terms = v ?? false),
        title: const Text(
          'Bedingungen und Selbstbehalt von CHF 1’500 bestätigen',
        ),
      ),
      CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        value: cancellation,
        onChanged: (v) => setState(() => cancellation = v ?? false),
        title: const Text('Stornoregeln bestätigen (kostenlos bis 2 h vorher)'),
      ),
    ],
  );
  Widget _review(dynamic state, Hub hub) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Zahlungsübersicht',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 14),
      _ReviewRow(
        'Fahrzeug',
        '${widget.vehicle.model} ${widget.vehicle.variant}',
      ),
      _ReviewRow('Abholung', hub.name),
      _ReviewRow(
        'Start',
        '${start.day}.${start.month}.${start.year} · ${two(start.hour)}:${two(start.minute)}',
      ),
      _ReviewRow('Paket', packageLabel(drivePackage)),
      if (delivery) const _ReviewRow('Haustürlieferung', 'CHF 39.00'),
      const Divider(height: 30),
      _ReviewRow('Gesamtbetrag', chf(price), strong: true),
      const SizedBox(height: 18),
      if (price > 0)
        const DemoNotice(
          text: 'Simulierte Zahlung · Testkarte •••• 4242 · es wird nichts belastet',
        )
      else
        const DemoNotice(
          text:
              'Kostenlose Basisfahrt · korrekte Zahlungsfreigabe mit CHF 0.00',
        ),
      const SizedBox(height: 18),
      const Text(
        'Mit dem Abschluss wird nur ein lokaler Demo-Datensatz erzeugt. Es entsteht kein Vertrag.',
      ),
    ],
  );

  Future<void> next(dynamic state) async {
    if (step == 2) {
      if (state.verificationStatus != VerificationStatus.verified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bitte zuerst Demo-Verifizierung abschliessen.'),
          ),
        );
        return;
      }
      if (!terms || !cancellation) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bitte beide Bedingungen bestätigen.')),
        );
        return;
      }
    }
    if (step < 3) {
      setState(() => step++);
      return;
    }
    setState(() => loading = true);
    try {
      final paymentReference = await SandboxPaymentAdapter().authorize(price);
      state.recordPayment(PaymentSimulation(paymentReference, price, true));
      final booking = state.createBooking(
        vehicle: widget.vehicle,
        start: start,
        drivePackage: drivePackage,
        homeDelivery: delivery,
      );
      if (!mounted) {
        return;
      }
      AppRouter.replace(context, BookingConfirmationScreen(booking: booking));
    } on StateError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  static String two(int v) => v.toString().padLeft(2, '0');
  static String packageLabel(DrivePackage p) => switch (p) {
    DrivePackage.standard60 => '60 Minuten Standard',
    DrivePackage.extended90 => '90 Minuten Extended',
    DrivePackage.weekend => 'Wochenende Premium',
  };
}

class _PackageTile extends StatelessWidget {
  const _PackageTile({
    required this.value,
    required this.selected,
    required this.performance,
    required this.onTap,
  });
  final DrivePackage value;
  final bool selected;
  final bool performance;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final price = packagePriceRappen(value, performance: performance);
    final title = BookingFlowScreenStateX.label(value);
    final sub = switch (value) {
      DrivePackage.standard60 => 'Mo–Fr · zentraler Hub',
      DrivePackage.extended90 => 'Mehr Zeit für deinen Alltag',
      DrivePackage.weekend => '48 Stunden · Premium-Demo',
    };
    return Card(
      color: selected ? AppColors.surfaceHigh : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? AppColors.copper : AppColors.line,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: selected ? AppColors.copper : AppColors.muted,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(sub),
        trailing: Text(
          chf(price),
          style: const TextStyle(
            color: AppColors.copper,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

extension BookingFlowScreenStateX on BookingFlowScreen {
  static String label(DrivePackage p) => switch (p) {
    DrivePackage.standard60 => 'Standard 60',
    DrivePackage.extended90 => 'Extended 90',
    DrivePackage.weekend => 'Weekend',
  };
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow(this.label, this.value, {this.strong = false});
  final String label;
  final String value;
  final bool strong;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: AppColors.cream,
              fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
              fontSize: strong ? 18 : 14,
            ),
          ),
        ),
      ],
    ),
  );
}

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({required this.booking, super.key});
  final Booking booking;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final vehicle = state.vehicleById(booking.vehicleId);
    final hub = state.hubById(booking.hubId);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const BrandMark(compact: true),
      ),
      body: PageWidth(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: ListView(
              children: [
                const SizedBox(height: 12),
                const Icon(
                  Icons.check_circle,
                  size: 68,
                  color: AppColors.success,
                ),
                const SizedBox(height: 16),
                Text(
                  'Deine Probefahrt ist bereit.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'Buchung ${booking.reference}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.copper,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        VehiclePhoto(
                          vehicle.imageAsset,
                          key: const ValueKey(
                            'booking-confirmation-vehicle-image',
                          ),
                          fit: BoxFit.cover,
                          semanticLabel:
                              '${vehicle.model} ${vehicle.variant}, gebuchtes Fahrzeug',
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Color(0xD9080D16)],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 18,
                          right: 18,
                          bottom: 15,
                          child: Text(
                            '${vehicle.model} ${vehicle.variant}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CustomPaint(
                          size: const Size(132, 132),
                          painter: _QrPainter(booking.reference),
                        ),
                        const SizedBox(height: 18),
                        _ReviewRow(
                          'Fahrzeug',
                          '${vehicle.model} ${vehicle.variant}',
                        ),
                        _ReviewRow('Hub', hub.name),
                        _ReviewRow(
                          'Datum',
                          '${booking.start.day}.${booking.start.month}.${booking.start.year}',
                        ),
                        _ReviewRow(
                          'Zeit',
                          '${booking.start.hour.toString().padLeft(2, '0')}:${booking.start.minute.toString().padLeft(2, '0')} Uhr',
                        ),
                        _ReviewRow(
                          'Paket',
                          BookingFlowScreenStateX.label(booking.drivePackage),
                        ),
                        _ReviewRow(
                          'Lieferung',
                          booking.homeDelivery
                              ? 'Haustürlieferung · Demo'
                              : 'Abholung am Hub',
                        ),
                        _ReviewRow(
                          'Preis',
                          chf(booking.priceRappen),
                          strong: true,
                        ),
                        const SizedBox(height: 8),
                        const StatusPill('BESTÄTIGT', icon: Icons.verified),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const DemoNotice(
                  text: 'E-Mail-Vorschau lokal erstellt · keine echte Nachricht versendet',
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () => AppRouter.replace(
                    context,
                    const MainShell(initialIndex: 1),
                  ),
                  child: const Text('Zu meinen Buchungen'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text('Zur Startseite'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    final end = booking.start.add(
                      Duration(minutes: packageMinutes(booking.drivePackage)),
                    );
                    final created = downloadTextFile(
                      filename: '${booking.reference}.ics',
                      mimeType: 'text/calendar;charset=utf-8',
                      content:
                          'BEGIN:VCALENDAR\r\n'
                          'VERSION:2.0\r\n'
                          'PRODID:-//Instant Drive Demo//DE\r\n'
                          'BEGIN:VEVENT\r\n'
                          'UID:${booking.reference}@instant-drive.demo\r\n'
                          'DTSTART:${calendarTimestamp(booking.start)}\r\n'
                          'DTEND:${calendarTimestamp(end)}\r\n'
                          'SUMMARY:Demo-Probefahrt ${vehicle.model}\r\n'
                          'LOCATION:${hub.name}, ${hub.address}\r\n'
                          'DESCRIPTION:Fiktiver MVP – keine echte Fahrzeugreservierung.\r\n'
                          'END:VEVENT\r\n'
                          'END:VCALENDAR\r\n',
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          created ? 'Kalendereintrag lokal heruntergeladen.' : 'Kalendereintrag ist in der Web-Version als Download verfügbar.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: const Text('Kalendereintrag herunterladen'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    if (printCurrentPage()) return;
                    showInfoDialog(
                      context,
                      'Druckansicht',
                      'Buchungsbestätigung ${booking.reference}\n${vehicle.model} · ${hub.name}\n${chf(booking.priceRappen)}',
                    );
                  },
                  icon: const Icon(Icons.print_outlined),
                  label: const Text('Bestätigung drucken / PDF'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  _QrPainter(this.data);
  final String data;
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)),
      bg,
    );
    final p = Paint()..color = AppColors.ink;
    const n = 13;
    final cell = size.width / n;
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        final seed =
            (x * 17 + y * 31 + data.codeUnitAt((x + y) % data.length)) % 7;
        if (seed < 3 ||
            (x < 3 && y < 3) ||
            (x > 9 && y < 3) ||
            (x < 3 && y > 9)) {
          canvas.drawRect(
            Rect.fromLTWH(x * cell, y * cell, cell * .82, cell * .82),
            p,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
