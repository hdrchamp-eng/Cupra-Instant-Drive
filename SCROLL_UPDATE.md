# Scroll update — 23 September 2026

## Changes

- Landing and discovery viewports have one owned scroll controller each.
- Web wheel ticks interpolate over 120 ms instead of applying their entire
  displacement immediately. Repeated ticks accumulate; reverse input resets
  the pending destination to the current position, avoiding a delayed reversal.
- Touch drags and scrollbars can interrupt the animation. Reduced-motion users
  and native iOS retain the standard Flutter behaviour. No global wheel event
  interception is installed, so maps and nested controls retain their input.
- Web vehicle photos use browser-native image elements instead of repeatedly
  rasterizing photographs into Flutter's canvas. The hero's two gradients also
  use CSS. Native iOS retains Flutter image rendering.
- The original full-background hero image, crop and content layout are restored.
- The fixed lifetime of the admin price dialog's text controller is included.

## Validation

- `flutter analyze`: clean.
- `flutter test`: 33 tests passed, including four dedicated wheel regression
  tests (intermediate positions, repeated input/reversal, bounds/touch
  interruption, native fallback), responsive landing, map, booking, orders,
  persistence and admin Weekend price editing.
- Formatting: clean. iOS simulator build: successful.
- Local comparative 8-second scroll probe at DPR 2: the prior canvas-photo
  implementation produced only 3–6 rAF callbacks, with multi-second raster times.
  Browser-native photos produced 164 callbacks; median interval 50 ms, p95 83.4
  ms and recent raster times 36–58 ms in the JavaScript build. A WebAssembly
  probe showed recent raster times 30–49 ms but ran during compilation and is
  not a clean end-to-end cadence comparison. This is a substantial reduction in
  stalls, not evidence of a sustained 60 FPS result on this host.
- Local diagnostic scripts and the diagnostic entrypoint are not included in
  the published website; the production entrypoint is lib/main.dart.
- This does not constitute a 60 FPS guarantee. A browser rAF-cadence check is
  separate from a GPU frame-rendering measurement.

## Host caveat

The development Mac has 8 GB RAM. During this work it reported approximately
8 GB swap usage and under 600 MB free internal storage during compilation.
These conditions can affect the whole browser, regardless of website code.
Build output is on the user-authorized FABREEZE USB drive; system swap remains
on the internal drive. No unrelated applications or user files were removed.
