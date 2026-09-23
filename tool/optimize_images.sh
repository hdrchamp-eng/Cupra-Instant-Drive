#!/bin/sh
set -eu

mkdir -p assets/images/models/optimized

sips -Z 1280 -s format jpeg -s formatOptions 78 \
  assets/images/demo_hero.png --out assets/images/demo_hero.jpg >/dev/null

for name in raval born tavascan leon leon-sportstourer formentor terramar ateca; do
  sips -Z 1280 -s format jpeg -s formatOptions 78 \
    "assets/images/models/final/$name.png" \
    --out "assets/images/models/optimized/$name.jpg" >/dev/null
done

echo "Optimierte App-Bilder erstellt."
