# CUPRA Instant Drive – Flutter MVP

Ein lokal ausführbarer, fiktiver Flutter-Prototyp für autonome Probefahrten in der Schweiz. Keine offizielle Partnerschaft mit CUPRA, AMAG oder Zurich.

## Enthaltene Demo-Flows

- Landingpage, Listen-/Karten-Suche und Filter
- Fahrzeugdetail und Live-Demo-Zeitfenster
- Demo-Anmeldung, Registrierung und Verifizierung
- kostenlose und Premium-Buchung mit Doppelbuchungsschutz
- Buchungsbestätigung mit QR-Demo, Kalender- und Druckaktionen
- Dashboard, Favoriten, Profil und Benachrichtigungen
- Standort-, Schaden-, Keyless-, Fahrt- und Rückgabe-Sandbox
- Feedback, Kauf/Leasing/Abo, Trade-in, Versicherung und Bestellbestätigung
- rollenbasierter Demo-Adminbereich mit KPIs, Flottenstatus und Audit-Historie
- vollständige aktuelle Modellpalette mit modellgenauen, lokal bearbeiteten Produktmotiven

## GitHub Pages

Die fertige Website liegt in `docs/` und wird über GitHub Pages veröffentlicht. Anleitung: [PUBLISHING.md](PUBLISHING.md). Hinweise zum Scroll-Update: [PERFORMANCE.md](PERFORMANCE.md).

Vorgesehene URL: https://hdrchamp-eng.github.io/Cupra-Instant-Drive/

Getesteter Werkzeugstand: Flutter 3.47.1 / Dart 3.13.1. Quellcode, Assets und native Plattformprojekte sind enthalten; lokale Caches, Schlüssel und Videos nicht.

## Start

Das Projekt klonen und mit dem lokal installierten Flutter SDK starten.

Die App bleibt im Simulator installiert und kann dort wie eine normale iPhone-App über das Instant-Drive-Icon oder die Suche geöffnet werden. Nur ein Zurücksetzen/Löschen des Simulators entfernt sie.

```bash
flutter pub get
flutter run
```

Die App startet ohne API-Schlüssel mit zentralen Seed-Daten. Ein maschinenlesbarer Seed-Export lässt sich so prüfen:

```bash
dart run tool/seed_demo.dart
```

Für iOS:

```bash
open -a Simulator
flutter devices
flutter run -d <simulator-id>
```

Für Web/PWA:

```bash
flutter run -d chrome
flutter build web --release --base-href /Cupra-Instant-Drive/
```

`web/manifest.json`, `robots.txt`, `sitemap.xml` und Open-Graph-Metadaten sind vorbereitet. Vor einem öffentlichen Deployment müssen Demo-Domain, Markenfreigaben und Rechtstexte ersetzt werden.

## Architektur und lokale Daten

- UI und Navigation: `lib/features` und `lib/app`
- Zentrale Seed-Daten: `lib/core/data/demo_seed.dart`
- Domänenmodelle und Statuswerte: `lib/core/models/models.dart`
- Preis-, Konflikt- und Statuslogik: `lib/core/utils/booking_logic.dart`
- Externe Systeme: austauschbare Adapter in `lib/core/services`
- Persistenz: versioniertes JSON in `SharedPreferences`; Implementierung in `lib/core/repositories`

Die App speichert keine Passwörter, Dokumentbilder oder Zahlungsdaten. Buchung, Bestellung, Favoriten, Verifizierungs- und Fahrtstatus bleiben im Demo-Modus lokal erhalten.

## Mock-Provider austauschen

Die Interfaces `IdentityVerificationAdapter`, `KeylessAdapter`, `PaymentAdapter`, `EmailAdapter`, `InsuranceAdapter` und `MapAdapter` werden für Produktion separat implementiert und über eine Composition Root injiziert. Schlüssel gehören ausschliesslich in eine sichere Laufzeitumgebung. Serverseitige Buchungstransaktionen, Rate Limits, Authentifizierung und Audit-Logging sind vor einem Produktivbetrieb zwingend.

## Demo-Zugänge

- Nutzer: Schaltfläche `Demo-Anmeldung`; vorbelegte synthetische Daten
- Admin: Schaltfläche `Als Demo-Admin anmelden`
- Dokumentprüfung, Zahlung, E-Mail, Versicherung, Karte und Keyless sind klar bezeichnete Sandbox-Funktionen

## Qualität

```bash
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
flutter build ios --simulator
```

Der am 23. September 2026 geprüfte Stand besteht alle 25 automatisierten Tests. Der lokale Release-Webbuild kann mit `python3 tool/serve_web.py` bereitgestellt werden; dafür ohne Pages-Unterpfad bauen. Die eingebundenen Laufzeitbilder sind auf 1.280 Pixel optimiert.

Demo-Nutzer: Schaltfläche `Demo-Anmeldung`. Demo-Admin: `Als Demo-Admin anmelden`.

Weitere Details: [agent.md](agent.md), [Veröffentlichung](PUBLISHING.md) und [Asset-Hinweise](ASSET_NOTICE.md).
