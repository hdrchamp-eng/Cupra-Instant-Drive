# Web performance update — 23 September 2026

- Replaced the landing page's nested single-child scroll container with a lazy SliverList: off-screen sections no longer share one giant layout/paint subtree.
- Isolated the hero image and gradients with a RepaintBoundary. List sections receive Flutter's automatic repaint boundaries.
- Release website compiled to WebAssembly, with JavaScript fallback for unsupported browsers.
- Regression test scrolls the complete desktop landing page to the footer and back and checks for layout errors and nested scroll owners.
- Local validation: 26 automated tests passed; flutter analyze clean. These checks are not a measured FPS guarantee on every device.

Build: `flutter build web --release --wasm --base-href /Cupra-Instant-Drive/`
