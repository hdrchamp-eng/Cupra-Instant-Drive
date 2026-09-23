# CUPRA Instant Drive – verbindliche Agenten- und Projektstruktur

## 1. Auftrag und Prioritäten

Dieses Dokument ist die verbindliche technische Leitlinie für das gesamte Projekt. Jede Implementierung wird daran geprüft. Bei Konflikten gelten in dieser Reihenfolge:

1. Sicherheit, Datenschutz und klare Kennzeichnung als fiktiver Prototyp
2. Bedienbarer End-to-End-Happy-Path ohne Sackgassen
3. Flutter-native, responsive und barrierearme Umsetzung
4. Zentrale, editierbare Demo-Daten statt verstreuter UI-Hardcodes
5. Verständliche Architektur und automatisierte Tests

Das Produkt ist keine offizielle App von CUPRA, AMAG oder Zurich. Zahlungen, Identitätsprüfung, Fahrzeugzugriff, Versicherungen, Verträge und Bestellungen werden ausschliesslich als sichere Sandbox simuliert.

## 2. Zielplattform und Stack

- Framework: Flutter, stabile lokal installierte Version
- Sprache: Dart mit strikter statischer Analyse
- Ziel: iOS-Simulator als primäre Demo, zusätzlich responsive Web-/Android-Kompatibilität
- State Management: Flutter SDK (`ChangeNotifier`/`ValueListenable`) in klar abgegrenzten Controllern; keine unnötige externe Abhängigkeit
- Navigation: zentraler, typisierter App-Router mit Auth- und Onboarding-Guards
- Persistenz: Repository-Schnittstellen plus lokale Demo-Implementierung; keine sensiblen Dokumentdaten speichern
- Kartenansicht: `flutter_map` mit OpenStreetMap-Kacheln, echter Zoom-/Pan-Interaktion, sichtbarer Attribution und anklickbaren CUPRA-Pins; bei fehlendem Netz bleibt die restliche App bedienbar
- Integrationen: ausschliesslich über Adapter-Interfaces mit Mock-/Sandbox-Implementierungen
- Design: eigene Tokens und wiederverwendbare Komponenten, keine Screens mit verstreuten Farb-/Abstandswerten
- Web-Performance: Laufzeitbilder maximal 1.280 Pixel breit und komprimiert einbinden; PNG-Master bleiben ausserhalb des Asset-Bundles. Der lokale Release-Server liefert Cache-Header und die Web-App zeigt während des Engine-Starts einen Marken-Ladezustand.

## 3. Verzeichnisstruktur

```text
cupra_instant_drive/
├── agent.md
├── README.md
├── REQUIREMENTS.md
├── pubspec.yaml
├── analysis_options.yaml
├── assets/
│   ├── images/
│   └── data/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart
│   │   ├── router.dart
│   │   └── app_state.dart
│   ├── core/
│   │   ├── design/          # Farben, Typografie, Abstände, Theme
│   │   ├── models/          # Domänenmodelle und Statuswerte
│   │   ├── repositories/    # Verträge für Datenzugriff
│   │   ├── services/        # Adapter-Verträge und Sandbox-Dienste
│   │   ├── data/            # Seed-Daten und lokale Repositories
│   │   ├── utils/           # Formatter, Validierung, Preislogik
│   │   └── widgets/         # globale UI-Bausteine
│   └── features/
│       ├── landing_discovery.dart    # Landing, Suche, Karte, Details-Einstieg
│       ├── booking_auth.dart         # Auth, Registrierung, Details, Buchung
│       └── dashboard_trip_order.dart # Dashboard, Fahrt, Angebot, Admin
├── tool/
│   └── seed_demo.dart                # maschinenlesbarer Seed-Export
├── docs/
│   └── LOCAL_DATA_SCHEMA.md          # Persistenzschema und Migrationen
├── web/
│   ├── manifest.json
│   ├── robots.txt
│   └── sitemap.xml
└── test/
    ├── unit/
    ├── integration/
    └── widget/
```

Die drei Feature-Dateien bilden kompakte vertikale MVP-Slices. Sobald ein Slice unabhängig weiterentwickelt wird oder 1'500 Zeilen überschreitet, wird er ohne Änderung der Domänen-API in `presentation`, `controller` und `widgets` geteilt. Geschäftslogik bleibt unabhängig davon in `AppState`, Repositories, Services und Utilities.

## 4. Domänenmodell

Zentrale Entitäten: `User`, `UserProfile`, `DriverVerification`, `Hub`, `Vehicle`, `VehicleImage`, `AvailabilitySlot`, `Booking`, `BookingAddon`, `PaymentSimulation`, `CheckIn`, `DamageReport`, `Trip`, `ReturnInspection`, `Favorite`, `Feedback`, `Offer`, `VehicleOrder`, `InsuranceSelection`, `TradeInEstimate`, `NotificationItem`, `AuditEvent`.

Regeln:

- Jede Entität besitzt eine eindeutige String-ID und relevante Zeitstempel.
- Statuswerte werden als Dart-Enums modelliert, nicht als freie Strings.
- Statuswechsel laufen über zentrale, testbare Methoden.
- Geld wird intern als ganze Rappen (`int`) gespeichert und als CHF formatiert.
- Buchungszeiten sind konfliktgeprüft; überlappende aktive Buchungen desselben Fahrzeugs sind verboten.
- Seed-Daten liegen zentral in `lib/core/data/demo_seed.dart`.
- Das lokale Persistenzschema ist versioniert und in `docs/LOCAL_DATA_SCHEMA.md` dokumentiert.

## 5. Zustands- und Datenfluss

```text
Screen/Widget → Feature Controller → Repository/Service Interface → Demo Adapter
             ← immutable View State / domain result             ←
```

- `AppState` hält nur sitzungsweite Zustände: Anmeldung, Nutzer, Verifizierung, Favoriten, Buchungen, aktive Fahrt, Bestellung und Demo-Admin-Rolle.
- Filter- und Formularzustände bleiben in den jeweiligen Feature-Controllern.
- Navigation erhält IDs und lädt die zugehörigen Modelle zentral; keine kompletten Modelle als unkontrollierte Kopien.
- Formularwerte bleiben bei Validierungsfehlern erhalten.
- Lade-, Leer-, Fehler- und Erfolgszustände werden sichtbar umgesetzt.

## 6. Produktfluss und Navigation

Primärer Happy Path:

1. Landingpage → Fahrzeuge finden
2. Listen-/Kartenansicht → Fahrzeugdetail
3. Anmeldung/Registrierung → Demo-Verifizierung
4. Mehrschritt-Buchung → kostenlose oder Premium-Bestätigung
5. Dashboard → Check-in → Keyless-Simulation → aktive Fahrt → Rückgabe
6. Feedback → Kauf/Leasing/Abo konfigurieren → unverbindliche Bestellung → Bestätigung

Sekundär: Profil, Favoriten, Benachrichtigungen, Support sowie rollenbasierter Demo-Adminbereich.

Jede Ansicht hat mindestens eine klare Weiter- oder Rücknavigation. Kein sichtbarer CTA bleibt ohne Funktion; nicht verfügbare reale Integrationen liefern ein erklärtes Sandbox-Ergebnis.

## 7. Designsystem

- Stil: dunkel, hochwertig, technisch, automotive
- Farben: fast schwarzer Hintergrund, warme Kupfer-/Terrakotta-Akzente, helles Off-White, semantische Statusfarben
- Typografie: starke, kompakte Headlines; gut lesbarer Fliesstext; skalierbare System-/Bundle-Schrift
- Formen: präzise Karten, moderate Rundungen, subtile Linien und Flächen statt übermässiger Schatten
- Komponenten: `PrimaryButton`, `SecondaryButton`, `AppCard`, `StatusChip`, `SectionHeader`, `PriceLabel`, `DemoNotice`, `EmptyState`, `AppTextField`, `BottomActionBar`
- Responsive Breakpoints: kompakt < 600, mittel 600–1023, gross ≥ 1024 logische Pixel
- Mindest-Touch-Ziel: 48 × 48; sichtbare Fokuszustände; semantische Labels; ausreichender Kontrast

## 8. Sicherheit und Datenschutz

- Nur synthetische Demo-Daten verwenden.
- Keine echten Ausweis-/Führerscheinbilder annehmen oder persistieren.
- Keine Secrets in Code, Seeds, Logs oder Client Storage.
- Standort nur nach aktiver Zustimmung; bei Ablehnung Zürich als Demo-Standort.
- Externe Aktionen (Zahlung, ID, Telematik, E-Mail, Versicherung) sind Adapter und standardmässig sichere Mocks.
- Rechtstexte sind deutlich als Platzhalter und nicht als Rechtsberatung markiert.
- Geschützte Routen prüfen Login und erforderlichen Status.

## 9. Tests und Qualitäts-Gates

Vor Abschluss müssen erfolgreich laufen:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build ios --simulator
```

Mindestens zu testen:

- Preisberechnung inklusive CHF 0.00
- Filter-/Suchlogik und Sortierung
- Verfügbarkeits- und Doppelbuchungslogik
- erlaubte und unerlaubte Statusübergänge
- Registrierung/Login im Demo-Modus
- kostenlose und Premium-Buchung
- Check-in, Fahrt und Rückgabe
- Angebot, fiktive Bestellung und Bestätigung
- wichtige Screens in kompakter und breiter Grösse
- Laufzeitbilder existieren und bleiben unter dem festgelegten Grössenbudget

## 10. Arbeitsregeln

- Vor Änderungen zuerst dieses Dokument prüfen.
- Kleine Unklarheiten mit dokumentierten, plausiblen Annahmen lösen.
- Externe Abhängigkeiten nur einsetzen, wenn sie echten Mehrwert bringen und lokal stabil funktionieren.
- Bestehende funktionierende Teile nicht durch grossflächige Umbauten gefährden.
- Nach jedem abgeschlossenen Feature formatieren, analysieren und relevante Tests ausführen.
- Offene externe Voraussetzungen in `MISSING_INFORMATION.md` sammeln; nur stoppen, wenn ohne Nutzerangabe kein sinnvoller Fortschritt mehr möglich ist.
- Die App am Ende im Simulator starten und den zentralen Flow sichtbar bereitstellen.
