import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';

import '../app/app.dart';
import '../app/router.dart';
import '../core/data/demo_seed.dart';
import '../core/design/app_theme.dart';
import '../core/models/models.dart';
import '../core/utils/discovery_logic.dart';
import '../core/widgets/common.dart';
import 'booking_auth.dart';
import 'dashboard_trip_order.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          toolbarHeight: 70,
          title: const BrandMark(compact: true),
          actions: [
            TextButton(
              onPressed: () => AppRouter.push(context, const AuthScreen()),
              child: Text(
                AppScope.of(context).loggedIn ? 'Profil' : 'Anmelden',
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: FilledButton(
                onPressed: () => AppRouter.push(context, const MainShell()),
                child: const Text('Demo starten'),
              ),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: _Hero(
            onStart: () => AppRouter.push(context, const MainShell()),
          ),
        ),
        const SliverToBoxAdapter(child: _LandingBody()),
      ],
    ),
  );
}

class _Hero extends StatelessWidget {
  const _Hero({required this.onStart});
  final VoidCallback onStart;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final compact = c.maxWidth < 900;
      final heroHeight = c.maxWidth < 500 ? 840.0 : (compact ? 720.0 : 700.0);
      return SizedBox(
        height: heroHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/demo_hero.jpg',
              fit: BoxFit.cover,
              alignment: compact ? const Alignment(.35, 0) : Alignment.center,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.ink.withValues(alpha: .98),
                    AppColors.ink.withValues(alpha: compact ? .58 : .2),
                    AppColors.ink.withValues(alpha: .28),
                  ],
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.ink.withValues(alpha: .93),
                  ],
                ),
              ),
            ),
            PageWidth(
              padding: EdgeInsets.fromLTRB(
                compact ? 22 : 50,
                compact ? 86 : 120,
                22,
                42,
              ),
              child: Align(
                alignment: compact
                    ? Alignment.bottomLeft
                    : Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 610),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const StatusPill(
                        '24/7 · ZÜRICH & BASEL',
                        color: AppColors.copper,
                        icon: Icons.bolt,
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Einsteigen.\nTesten. Verlieben.',
                        style: compact
                            ? Theme.of(context).textTheme.displayMedium
                            : Theme.of(context).textTheme.displayLarge,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Deine autonome Probefahrt in unter 3 Minuten. 60–90 Minuten ohne Verkaufsdruck, mit digitaler Verifizierung und schlüssellosem Zugang.',
                        style: Theme.of(context).textTheme.bodyLarge
                            ?.copyWith(color: const Color(0xFFD6DBE3)),
                      ),
                      const SizedBox(height: 28),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.icon(
                            onPressed: onStart,
                            icon: const Icon(Icons.near_me_outlined),
                            label: const Text('CUPRA in der Nähe finden'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => showInfoDialog(
                              context,
                              'So funktioniert die Demo',
                              'Suche ein Fahrzeug, verifiziere dich mit synthetischen Daten, buche eine Fahrt und simuliere Check-in, Entriegelung, Rückgabe und Bestellung.',
                            ),
                            icon: const Icon(Icons.play_circle_outline),
                            label: const Text('Ablauf ansehen'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'FIKTIVER MVP · KEINE OFFIZIELLE MARKENPARTNERSCHAFT',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.muted,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _LandingBody extends StatelessWidget {
  const _LandingBody();
  @override
  Widget build(BuildContext context) => PageWidth(
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 34),
          const SectionTitle(
            'Probefahren, wie es heute sein sollte.',
            kicker: 'Warum Instant Drive',
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, c) {
              final count = c.maxWidth > 900 ? 3 : 1;
              return GridView.count(
                crossAxisCount: count,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: count == 3 ? 1.55 : 2.35,
                children: const [
                  _Benefit(
                    Icons.phone_iphone,
                    'App auf. CUPRA auf.',
                    'Führerschein und ID im sicheren Demo-Modus prüfen. Danach schlüssellos starten.',
                  ),
                  _Benefit(
                    Icons.location_city_outlined,
                    'Mitten in deiner Stadt',
                    'Fahrzeuge an Bahnhöfen, Einkaufszentren und zentralen Parkhäusern.',
                  ),
                  _Benefit(
                    Icons.no_accounts_outlined,
                    '0 % Verkaufsdruck',
                    'Teste Reichweite, Platz und Fahrgefühl in deinem echten Alltag.',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 64),
          const SectionTitle(
            'In vier Schritten auf die Strasse.',
            kicker: 'Unter 3 Minuten startbereit',
          ),
          const SizedBox(height: 22),
          const Wrap(
            runSpacing: 12,
            children: [
              _Step(
                '01',
                'Fahrzeug wählen',
                'Alle aktuellen CUPRA Modelle vergleichen und am passenden Hub finden.',
              ),
              _Step(
                '02',
                'Sicher verifizieren',
                'Synthetischer ID- und Führerscheincheck ohne Dokumentübertragung.',
              ),
              _Step(
                '03',
                'Keyless starten',
                'Fahrzeug finden, Zustand prüfen und Entriegelung simulieren.',
              ),
              _Step(
                '04',
                'Direkt entscheiden',
                'Nach der Rückgabe Kauf, Leasing oder Auto-Abo konfigurieren.',
              ),
            ],
          ),
          const SizedBox(height: 64),
          const SectionTitle(
            'Deine Fahrt. Dein Paket.',
            kicker: 'Transparent in CHF',
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, c) {
              const standard = _PriceCard(
                'STANDARD',
                'CHF 0.00',
                '60 Minuten · Mo–Fr',
                ['Zentraler Hub', 'Basisversicherung', 'Keyless-Sandbox'],
              );
              const extended = _PriceCard(
                'EXTENDED',
                'CHF 29.00',
                '90 Minuten',
                ['Mehr Zeit im Alltag', 'Flexible Slots', 'Optional Lieferung'],
                featured: true,
              );
              const weekend = _PriceCard(
                'WEEKEND',
                'CHF 79.00',
                '48 Stunden · Demo',
                ['Langzeittest', 'Performance verfügbar', 'Premium Support'],
              );
              if (c.maxWidth > 720) {
                return const IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: standard),
                      SizedBox(width: 14),
                      Expanded(child: extended),
                      SizedBox(width: 14),
                      Expanded(child: weekend),
                    ],
                  ),
                );
              }
              return const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  standard,
                  SizedBox(height: 14),
                  extended,
                  SizedBox(height: 14),
                  weekend,
                ],
              );
            },
          ),
          const SizedBox(height: 64),
          const SectionTitle(
            'Wähle deinen Alltagstest.',
            kicker: 'Demo-Fahrzeuge',
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 960 ? 3 : 1;
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: columns == 3 ? 1.05 : 1.8,
                children: [
                  for (final vehicle in demoVehicles)
                    _PublicVehicleCard(
                      vehicle: vehicle,
                      onTap: () => AppRouter.push(
                        context,
                        VehicleDetailScreen(vehicle: vehicle),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 64),
          const SectionTitle(
            'Dort, wo du ohnehin bist.',
            kicker: 'Hubs in der Schweiz',
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final hub in demoHubs)
                _HubPreviewCard(
                  hub: hub,
                  onTap: () => AppRouter.push(context, const MainShell()),
                ),
            ],
          ),
          const SizedBox(height: 64),
          const SectionTitle(
            'Häufig gefragt.',
            kicker: 'Sicherheit & Datenschutz',
          ),
          const SizedBox(height: 12),
          const _Faq(
            'Ist das eine echte Fahrzeugbuchung?',
            'Nein. Dieser MVP ist ein fiktiver Prototyp. Fahrzeuge, Zahlungen, Versicherungen und Entriegelungen werden ausschliesslich simuliert.',
          ),
          const _Faq(
            'Werden Ausweis oder Führerschein gespeichert?',
            'Nein. Nutze nur den integrierten Demo-Erfolgspfad. Es werden keine Dokumentbilder übertragen oder gespeichert.',
          ),
          const _Faq(
            'Was ist versichert?',
            'Die angezeigten Versicherungs- und Haftungsbedingungen sind Demo-Platzhalter und keine Rechtsberatung oder Deckungszusage.',
          ),
          const SizedBox(height: 42),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.line),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 18,
              children: [
                SizedBox(
                  width: 560,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bereit für 100 % Alltagstest?',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'Finde jetzt ein Demo-Fahrzeug in Zürich oder Basel.',
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => AppRouter.push(context, const MainShell()),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Fahrzeuge entdecken'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const Divider(),
          const SizedBox(height: 20),
          Wrap(
            spacing: 14,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const BrandMark(compact: true),
              TextButton(
                onPressed: () => showInfoDialog(
                  context,
                  'Impressum · Demo-Platzhalter',
                  'Fiktiver Hochschul-/Produktprototyp. Keine offizielle Partnerschaft mit CUPRA, AMAG oder Zurich. Vor Veröffentlichung durch geprüfte Anbieterangaben ersetzen.',
                ),
                child: const Text('Impressum'),
              ),
              TextButton(
                onPressed: () => showInfoDialog(
                  context,
                  'Datenschutz · Demo-Platzhalter',
                  'Es werden lokal nur minimale synthetische Demo-Daten gespeichert. Keine Dokumentbilder, Passwörter oder Zahlungsdaten. Für Auskunft oder Löschung kann der lokale Demo-Stand über „Abmelden“ zurückgesetzt werden.',
                ),
                child: const Text('Datenschutz'),
              ),
              TextButton(
                onPressed: () => showInfoDialog(
                  context,
                  'AGB · Demo-Platzhalter',
                  'Diese Ansicht ist keine Rechtsberatung. Es entstehen keine Reservierung, Zahlung, Versicherung und kein Kauf-, Leasing- oder Kreditvertrag.',
                ),
                child: const Text('AGB'),
              ),
              const Text(
                'Fiktiver MVP/Prototyp · Rechtstexte sind Platzhalter',
                style: TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _PublicVehicleCard extends StatelessWidget {
  const _PublicVehicleCard({required this.vehicle, required this.onTap});

  final Vehicle vehicle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Semantics(
              image: true,
              label: 'CUPRA ${vehicle.model} ${vehicle.variant}',
              child: Image.asset(
                vehicle.imageAsset,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${vehicle.model} ${vehicle.variant}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text('${vehicle.powertrain} · ${vehicle.power}'),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward, color: AppColors.copper),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _HubPreviewCard extends StatelessWidget {
  const _HubPreviewCard({required this.hub, required this.onTap});

  final Hub hub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 280,
    child: Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: AppColors.copper),
              const SizedBox(height: 12),
              Text(hub.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(hub.address),
              const SizedBox(height: 8),
              Text(
                '${hub.hours} · ${hub.distanceKm.toStringAsFixed(1)} km',
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Benefit extends StatelessWidget {
  const _Benefit(this.icon, this.title, this.text);
  final IconData icon;
  final String title;
  final String text;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.copper, size: 28),
          const Spacer(),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 7),
          Text(text),
        ],
      ),
    ),
  );
}

class _Step extends StatelessWidget {
  const _Step(this.number, this.title, this.text);
  final String number;
  final String title;
  final String text;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 280,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 24, 14),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: AppColors.copper, width: 3)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SCHRITT $number',
                style: const TextStyle(
                  color: AppColors.copper,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 5),
              Text(text),
            ],
          ),
        ),
      ),
    ),
  );
}

class _PriceCard extends StatelessWidget {
  const _PriceCard(
    this.name,
    this.price,
    this.subtitle,
    this.items, {
    this.featured = false,
  });
  final String name;
  final String price;
  final String subtitle;
  final List<String> items;
  final bool featured;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: featured ? AppColors.surfaceHigh : AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: featured ? AppColors.copper : AppColors.line,
        width: featured ? 1.5 : 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 11,
            letterSpacing: 1.3,
            color: AppColors.copper,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        Text(price, style: Theme.of(context).textTheme.headlineLarge),
        Text(subtitle),
        const SizedBox(height: 18),
        ...items.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.check, size: 17, color: AppColors.success),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    e,
                    style: const TextStyle(color: AppColors.cream),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _Faq extends StatelessWidget {
  const _Faq(this.question, this.answer);
  final String question;
  final String answer;
  @override
  Widget build(BuildContext context) => Card(
    child: ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      children: [Align(alignment: Alignment.centerLeft, child: Text(answer))],
    ),
  );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});
  final int initialIndex;
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int index = widget.initialIndex;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final pages = <Widget>[
      const DiscoveryScreen(),
      const DashboardScreen(),
      const ProfileScreen(),
      if (state.isAdmin) const AdminScreen(),
    ];
    if (index >= pages.length) index = 0;
    return Scaffold(
      appBar: AppBar(
        title: const BrandMark(compact: true),
        actions: [
          IconButton(
            tooltip: 'Benachrichtigungen',
            onPressed: () => showInfoDialog(
              context,
              'Benachrichtigungen',
              'Du hast keine neuen Benachrichtigungen. Erinnerungen werden in dieser Demo lokal simuliert.',
            ),
            icon: const Icon(Icons.notifications_none),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car),
            label: 'Entdecken',
          ),
          const NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'Fahrten',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
          if (state.isAdmin)
            const NavigationDestination(
              icon: Icon(Icons.admin_panel_settings_outlined),
              label: 'Admin',
            ),
        ],
      ),
    );
  }
}

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});
  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  final searchController = TextEditingController();
  String query = '';
  String model = 'Alle';
  String powertrain = 'Alle';
  VehicleSort sortMode = VehicleSort.distance;
  DrivePackage? packageFilter;
  bool deliveryOnly = false;
  double maxDistance = 150;
  bool availableOnly = false;
  bool mapMode = false;
  bool permissionAsked = false;
  bool searchLoading = false;
  String? searchError;

  List<String> get modelNames => [
    'Alle',
    ...demoVehicles.map((vehicle) => vehicle.model).toSet(),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Vehicle> get filtered => filterAndSortVehicles(
    vehicles: demoVehicles,
    hubs: demoHubs,
    slotsFor: demoSlotsFor,
    query: query,
    model: model,
    powertrain: powertrain,
    availableOnly: availableOnly,
    maxDistance: maxDistance,
    sort: sortMode,
    drivePackage: packageFilter,
    homeDelivery: deliveryOnly,
  );

  Future<void> _showMoreFilters() async {
    final selection = await showModalBottomSheet<_MoreFilterSelection>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _MoreFilters(
        initial: _MoreFilterSelection(
          powertrain: powertrain,
          drivePackage: packageFilter,
          deliveryOnly: deliveryOnly,
          maxDistance: maxDistance,
        ),
      ),
    );
    if (selection == null || !mounted) return;
    setState(() {
      powertrain = selection.powertrain;
      packageFilter = selection.drivePackage;
      deliveryOnly = selection.deliveryOnly;
      maxDistance = selection.maxDistance;
    });
  }

  @override
  Widget build(BuildContext context) => PageWidth(
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final heading = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CUPRA in deiner Nähe',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 4),
                  const Text('Alle aktuellen Modelle · Zürich, Basel und Bern'),
                ],
              );
              final viewSwitch = SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: false,
                    icon: Icon(Icons.view_list),
                    label: Text('Liste'),
                  ),
                  ButtonSegment(
                    value: true,
                    icon: Icon(Icons.map_outlined),
                    label: Text('Karte'),
                  ),
                ],
                selected: {mapMode},
                onSelectionChanged: (v) => setState(() => mapMode = v.first),
              );
              if (constraints.maxWidth < 600) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [heading, const SizedBox(height: 14), viewSwitch],
                );
              }
              return Row(
                children: [
                  Expanded(child: heading),
                  viewSwitch,
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          TextField(
            controller: searchController,
            onChanged: (value) => setState(() => query = value),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Ort, PLZ, Hub oder Modell',
              suffixIcon: IconButton(
                tooltip: 'Standort verwenden',
                onPressed: () {
                  setState(() {
                    permissionAsked = true;
                    query = 'Zürich';
                    searchController.text = query;
                    searchController.selection = TextSelection.collapsed(
                      offset: query.length,
                    );
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Demo-Standort Zürich verwendet. Kein echter Standortzugriff.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.my_location),
              ),
            ),
          ),
          if (permissionAsked)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Standort-Sandbox aktiv · Zürich Zentrum',
                style: TextStyle(fontSize: 11, color: AppColors.copper),
              ),
            ),
          const SizedBox(height: 13),
          LayoutBuilder(
            builder: (context, constraints) {
              final modelPicker = DropdownButtonFormField<String>(
                initialValue: model,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'CUPRA Modell',
                  prefixIcon: Icon(Icons.directions_car_outlined),
                ),
                items: [
                  for (final item in modelNames)
                    DropdownMenuItem(value: item, child: Text(item)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => model = value);
                },
              );
              final actions = Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FilterChip(
                    avatar: const Icon(Icons.bolt, size: 18),
                    label: const Text('Nur verfügbare'),
                    selected: availableOnly,
                    onSelected: (v) => setState(() => availableOnly = v),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.tune, size: 18),
                    label: const Text('Weitere Filter'),
                    onPressed: _showMoreFilters,
                  ),
                ],
              );
              if (constraints.maxWidth < 720) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [modelPicker, const SizedBox(height: 10), actions],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 320, child: modelPicker),
                  const SizedBox(width: 12),
                  Expanded(child: actions),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Sortierung:',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              SizedBox(
                width: 235,
                child: DropdownButton<VehicleSort>(
                  value: sortMode,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: VehicleSort.distance,
                      child: Text('Entfernung'),
                    ),
                    DropdownMenuItem(
                      value: VehicleSort.earliestAvailability,
                      child: Text('Früheste Verfügbarkeit'),
                    ),
                    DropdownMenuItem(
                      value: VehicleSort.price,
                      child: Text('Preis'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => sortMode = value);
                  },
                ),
              ),
              if (powertrain != 'Alle') Chip(label: Text(powertrain)),
              if (packageFilter != null)
                Chip(label: Text(_packageFilterLabel(packageFilter!))),
              if (deliveryOnly) const Chip(label: Text('Lieferung')),
              Chip(label: Text('bis ${maxDistance.round()} km')),
            ],
          ),
          const SizedBox(height: 18),
          if (searchLoading)
            const _SearchLoading()
          else if (searchError case final message?)
            _SearchError(
              message: message,
              onRetry: () => setState(() => searchError = null),
            )
          else if (filtered.isEmpty)
            const _EmptySearch()
          else if (mapMode)
            _InteractiveMap(
              vehicles: filtered,
              onVehicle: (vehicle) => AppRouter.push(
                context,
                VehicleDetailScreen(vehicle: vehicle),
              ),
            )
          else ...[
            Text(
              '${filtered.length} Fahrzeuge · sortiert nach ${vehicleSortLabel(sortMode)}',
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, c) {
                final cols = c.maxWidth > 850 ? 2 : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: cols == 2 ? 385 : 350,
                  ),
                  itemBuilder: (_, i) => VehicleCard(
                    vehicle: filtered[i],
                    onTap: () => AppRouter.push(
                      context,
                      VehicleDetailScreen(vehicle: filtered[i]),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    ),
  );

  static String _packageFilterLabel(DrivePackage value) => switch (value) {
    DrivePackage.standard60 => '60 Min kostenlos',
    DrivePackage.extended90 => '90 Minuten',
    DrivePackage.weekend => 'Wochenende',
  };
}

class VehicleCard extends StatelessWidget {
  const VehicleCard({required this.vehicle, required this.onTap, super.key});
  final Vehicle vehicle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final hub = state.hubById(vehicle.hubId);
    final available = vehicle.status == VehicleStatus.available;
    final statusLabel = switch (vehicle.status) {
      VehicleStatus.available => 'VERFÜGBAR',
      VehicleStatus.reserved => 'RESERVIERT',
      VehicleStatus.inTrip => 'UNTERWEGS',
      VehicleStatus.charging => 'LÄDT',
      VehicleStatus.cleaning => 'REINIGUNG',
      VehicleStatus.maintenance => 'SERVICE',
      VehicleStatus.offline => 'OFFLINE',
    };
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Semantics(
                    image: true,
                    label: 'CUPRA ${vehicle.model} ${vehicle.variant}',
                    child: Image.asset(
                      vehicle.imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => ColoredBox(
                        color: AppColors.surfaceHigh,
                        child: const Center(
                          child: Icon(
                            Icons.directions_car,
                            size: 56,
                            color: AppColors.copper,
                          ),
                        ),
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.surface.withValues(alpha: .9),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: StatusPill(
                      statusLabel,
                      color: available ? AppColors.success : AppColors.warning,
                    ),
                  ),
                  Positioned(
                    top: 7,
                    right: 7,
                    child: IconButton.filledTonal(
                      tooltip: 'Favorit',
                      onPressed: () => state.toggleFavorite(vehicle.id),
                      icon: Icon(
                        state.favoriteIds.contains(vehicle.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: state.favoriteIds.contains(vehicle.id)
                            ? AppColors.copper
                            : AppColors.cream,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${vehicle.model} ${vehicle.variant}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward,
                        size: 18,
                        color: AppColors.copper,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${vehicle.powertrain} · ${vehicle.power} · ${vehicle.range}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${hub.name} · ${hub.distanceKm.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            color: AppColors.cream,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Text(
                        'ab CHF 0.00',
                        style: TextStyle(
                          color: AppColors.copper,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InteractiveMap extends StatefulWidget {
  const _InteractiveMap({required this.vehicles, required this.onVehicle});

  final List<Vehicle> vehicles;
  final ValueChanged<Vehicle> onVehicle;

  @override
  State<_InteractiveMap> createState() => _InteractiveMapState();
}

class _InteractiveMapState extends State<_InteractiveMap> {
  final MapController _controller = MapController();

  List<LatLng> get _hubPoints {
    final hubIds = widget.vehicles.map((vehicle) => vehicle.hubId).toSet();
    return demoHubs
        .where((hub) => hubIds.contains(hub.id))
        .map((hub) => LatLng(hub.latitude, hub.longitude))
        .toList();
  }

  void _fitHubs() {
    final points = _hubPoints;
    if (points.isEmpty) return;
    _controller.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: const EdgeInsets.fromLTRB(56, 80, 56, 88),
        maxZoom: 14,
      ),
    );
  }

  void _zoom(double delta) {
    final camera = _controller.camera;
    _controller.move(
      camera.center,
      (camera.zoom + delta).clamp(6, 18).toDouble(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final byHub = <String, List<Vehicle>>{};
    for (final vehicle in widget.vehicles) {
      byHub.putIfAbsent(vehicle.hubId, () => []).add(vehicle);
    }
    return Container(
      height: 520,
      decoration: BoxDecoration(
        color: const Color(0xFF17283A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _controller,
            options: MapOptions(
              initialCameraFit: CameraFit.bounds(
                bounds: LatLngBounds.fromPoints(_hubPoints),
                padding: const EdgeInsets.fromLTRB(48, 78, 48, 82),
                maxZoom: 14,
              ),
              minZoom: 6,
              maxZoom: 18,
              backgroundColor: const Color(0xFF17283A),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'ch.cupra.demo.cupraInstantDrive',
                maxNativeZoom: 19,
                tileBuilder: darkModeTileBuilder,
              ),
              MarkerLayer(
                markers: byHub.entries.map((entry) {
                  final hub = demoHubs.firstWhere(
                    (candidate) => candidate.id == entry.key,
                  );
                  final cluster = entry.value;
                  return Marker(
                    key: ValueKey('cupra-map-pin-${hub.id}'),
                    point: LatLng(hub.latitude, hub.longitude),
                    width: 66,
                    height: 72,
                    alignment: Alignment.topCenter,
                    child: Semantics(
                      button: true,
                      label:
                          '${cluster.length} ${cluster.length == 1 ? 'Fahrzeug' : 'Fahrzeuge'} bei ${hub.name}',
                      child: GestureDetector(
                        onTap: () => widget.onVehicle(cluster.first),
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceHigh,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.copper,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.copper.withValues(
                                      alpha: .48,
                                    ),
                                    blurRadius: 16,
                                  ),
                                ],
                              ),
                              child: SvgPicture.asset(
                                'assets/branding/cupra-symbol.svg',
                              ),
                            ),
                            if (cluster.length > 1)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 23,
                                  height: 23,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: AppColors.copper,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${cluster.length}',
                                    style: const TextStyle(
                                      color: AppColors.ink,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            Positioned(
                              top: 51,
                              child: Transform.rotate(
                                angle: .785,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  color: AppColors.copper,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const _MapAttribution(),
            ],
          ),
          const Positioned(left: 12, top: 12, child: _MapHint()),
          Positioned(
            right: 12,
            top: 12,
            child: Column(
              children: [
                _MapControl(
                  tooltip: 'Hineinzoomen',
                  icon: Icons.add,
                  onPressed: () => _zoom(1),
                ),
                const SizedBox(height: 6),
                _MapControl(
                  tooltip: 'Herauszoomen',
                  icon: Icons.remove,
                  onPressed: () => _zoom(-1),
                ),
                const SizedBox(height: 6),
                _MapControl(
                  tooltip: 'Alle Hubs anzeigen',
                  icon: Icons.center_focus_strong,
                  onPressed: _fitHubs,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapHint extends StatelessWidget {
  const _MapHint();

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxWidth: 230),
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.ink.withValues(alpha: .9),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.copper.withValues(alpha: .7)),
    ),
    child: const Text(
      'Interaktive Karte · ziehen, zoomen oder CUPRA-Pin wählen',
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
    ),
  );
}

class _MapAttribution extends StatelessWidget {
  const _MapAttribution();

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Align(
      alignment: Alignment.bottomRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 180),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        color: AppColors.ink.withValues(alpha: .84),
        child: const Text(
          '© OpenStreetMap contributors · flutter_map',
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: 8, height: 1.15),
        ),
      ),
    ),
  );
}

class _MapControl extends StatelessWidget {
  const _MapControl({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.ink.withValues(alpha: .94),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: const BorderSide(color: AppColors.line),
    ),
    child: IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, color: AppColors.cream),
    ),
  );
}

class _MoreFilterSelection {
  const _MoreFilterSelection({
    required this.powertrain,
    required this.drivePackage,
    required this.deliveryOnly,
    required this.maxDistance,
  });

  final String powertrain;
  final DrivePackage? drivePackage;
  final bool deliveryOnly;
  final double maxDistance;
}

class _MoreFilters extends StatefulWidget {
  const _MoreFilters({required this.initial});

  final _MoreFilterSelection initial;

  @override
  State<_MoreFilters> createState() => _MoreFiltersState();
}

class _MoreFiltersState extends State<_MoreFilters> {
  late String powertrain = widget.initial.powertrain;
  late DrivePackage? drivePackage = widget.initial.drivePackage;
  late bool deliveryOnly = widget.initial.deliveryOnly;
  late double maxDistance = widget.initial.maxDistance;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weitere Filter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 14),
            const Text(
              'Antrieb',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Alle', 'Elektro', 'Plug-in Hybrid', 'Benzin']
                  .map(
                    (value) => ChoiceChip(
                      label: Text(value),
                      selected: powertrain == value,
                      onSelected: (_) => setState(() => powertrain = value),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Text('Paket', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Alle Pakete'),
                  selected: drivePackage == null,
                  onSelected: (_) => setState(() => drivePackage = null),
                ),
                for (final value in DrivePackage.values)
                  ChoiceChip(
                    label: Text(
                      _DiscoveryScreenState._packageFilterLabel(value),
                    ),
                    selected: drivePackage == value,
                    onSelected: (_) => setState(() => drivePackage = value),
                  ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: deliveryOnly,
              onChanged: (value) => setState(() => deliveryOnly = value),
              title: const Text('Haustürlieferung verfügbar'),
              subtitle: const Text('Premium-Demo · CHF 39.00'),
            ),
            Text(
              'Maximale Entfernung: ${maxDistance.round()} km',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            Slider(
              value: maxDistance,
              min: 5,
              max: 150,
              divisions: 29,
              label: '${maxDistance.round()} km',
              onChanged: (value) => setState(() => maxDistance = value),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                TextButton(
                  onPressed: () => setState(() {
                    powertrain = 'Alle';
                    drivePackage = null;
                    deliveryOnly = false;
                    maxDistance = 150;
                  }),
                  child: const Text('Zurücksetzen'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () => Navigator.pop(
                    context,
                    _MoreFilterSelection(
                      powertrain: powertrain,
                      drivePackage: drivePackage,
                      deliveryOnly: deliveryOnly,
                      maxDistance: maxDistance,
                    ),
                  ),
                  child: const Text('Filter anwenden'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 70),
    child: Center(
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 48, color: AppColors.muted),
          const SizedBox(height: 12),
          Text(
            'Kein Fahrzeug gefunden',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 5),
          const Text(
            'Passe Ort oder Filter an. Zürich bleibt als Demo-Standort verfügbar.',
          ),
        ],
      ),
    ),
  );
}

class _SearchLoading extends StatelessWidget {
  const _SearchLoading();

  @override
  Widget build(BuildContext context) => const Card(
    child: Padding(
      padding: EdgeInsets.all(28),
      child: Row(
        children: [
          CircularProgressIndicator(strokeWidth: 2),
          SizedBox(width: 18),
          Expanded(
            child: Text('Demo-Fahrzeuge und Verfügbarkeiten werden geladen …'),
          ),
        ],
      ),
    ),
  );
}

class _SearchError extends StatelessWidget {
  const _SearchError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 44,
            color: AppColors.error,
          ),
          const SizedBox(height: 10),
          Text(
            'Suche nicht verfügbar',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 5),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: onRetry,
            child: const Text('Erneut versuchen'),
          ),
        ],
      ),
    ),
  );
}
