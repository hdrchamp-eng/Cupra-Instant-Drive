# GitHub Pages aktivieren

Die Website ist vorbereitet, aber noch nicht veröffentlicht.

1. Repository **Settings → Pages** öffnen.
2. **Source → Deploy from a branch** wählen.
3. Branch **main** und Ordner **/docs** wählen, dann **Save**.
4. Den Pages-Build abwarten.

Vorgesehene URL: https://hdrchamp-eng.github.io/Cupra-Instant-Drive/

Der Unterordner ist im Web-Build berücksichtigt. Keine eigene Domain oder API-Schlüssel erforderlich.

## Aktualisieren

Nach Quellcodeänderungen **Actions → Prepare CUPRA website → Run workflow** starten und **Rebuild from source** aktivieren. Der Workflow prüft die App und aktualisiert `docs/`. Solange Pages deaktiviert ist, erfolgt keine Veröffentlichung.

Alternativ lokal mit Flutter 3.47.1 / Dart 3.13.1:

```sh
flutter pub get
flutter analyze
flutter test
flutter build web --release --base-href /Cupra-Instant-Drive/
```

Danach den Inhalt von `build/web/` nach `docs/` kopieren, `docs/.nojekyll` beibehalten und committen.

## Vor öffentlicher Nutzung

Fiktiver Schul-/MVP-Prototyp, keine offizielle CUPRA-, AMAG- oder Zurich-App. Bestellungen, Identitätsprüfung, Zahlungen und Fahrzeugzugriff sind Simulationen. Marken-/Bildrechte und Rechtstexte vor einer öffentlichen Präsentation prüfen. Pages stellt nur die Web-App bereit, keinen produktiven Buchungsserver oder App-Store-Release.

Referenz: https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site
