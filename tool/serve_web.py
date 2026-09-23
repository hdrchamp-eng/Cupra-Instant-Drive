#!/usr/bin/env python3
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1] / "build" / "web"
HOST = "127.0.0.1"
PORT = 8765


class DemoHandler(SimpleHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def end_headers(self):
        path = self.path.split("?", 1)[0]
        if path.endswith((".jpg", ".png", ".svg", ".wasm", ".ttf", ".otf")):
            self.send_header("Cache-Control", "public, max-age=3600")
        else:
            self.send_header("Cache-Control", "no-cache")
        self.send_header("X-Content-Type-Options", "nosniff")
        super().end_headers()


if __name__ == "__main__":
    if not ROOT.joinpath("index.html").is_file():
        raise SystemExit("Web-Build fehlt. Zuerst `flutter build web --release` ausführen.")
    handler = partial(DemoHandler, directory=str(ROOT))
    server = ThreadingHTTPServer((HOST, PORT), handler)
    print(f"CUPRA Instant Drive läuft auf http://{HOST}:{PORT}", flush=True)
    server.serve_forever()
