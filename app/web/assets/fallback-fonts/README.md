# Web fallback fonts

The web build loads nothing from another host (D-40). When the bundled
Roboto lacks a glyph, Flutter's web engine fetches a Noto fallback font from
`fontFallbackBaseUrl` (set to `assets/fallback-fonts/` in
`web/flutter_bootstrap.js`) at the same path it would use on
fonts.gstatic.com. This folder holds those files for the families below, so
emoji and common symbols render on the web without a request leaving our
server (issue #15). Android and iOS use the system fonts.

Families not listed (CJK, other scripts) still show empty boxes on the web;
add them the same way when a need appears.

| Family | Why | Licence |
| --- | --- | --- |
| `notocoloremoji` | Emoji in names, notes and labels | OFL-1.1 (`notocoloremoji/OFL.txt`) |
| `notosanssymbols` | Common symbols | OFL-1.1 (`notosanssymbols/OFL.txt`) |
| `notosanssymbols2` | Arrows, check marks, shapes | OFL-1.1 (`notosanssymbols2/OFL.txt`) |

The paths come from the engine's font table, so they change when Flutter
changes. `tools/ci/web-fallback-fonts-check.mjs` reads the paths the built
app asks for and fails when a file is missing or no longer used; then
download the new paths with the loop below, replace the old version folders
and update the table. `test/platform/web_fallback_fonts_test.dart` checks
the hashes.

```sh
# from app/, after flutter build web
for p in $(grep -o '"\(notocoloremoji\|notosanssymbols2\?\)/v[^"]*"' build/web/main.dart.js | tr -d '"' | sort -u); do
  mkdir -p "web/assets/fallback-fonts/$(dirname "$p")"
  curl -sf -o "web/assets/fallback-fonts/$p" "https://fonts.gstatic.com/s/$p"
done
```

Flutter 3.50.0. Source: https://fonts.gstatic.com/s/ + path.

| File | Bytes | SHA-256 |
| --- | --- | --- |
| `notocoloremoji/v39/Yq6P-KqIXTD0t4D9z1ESnKM3-HpFabsE4tq3luCC7p-aXxcn.0.woff2` | 709628 | 1ea085e149cb9e5f1ac086f0580f7dc10d6cc06cb2e29caa8a7360064a7eadd6 |
| `notocoloremoji/v39/Yq6P-KqIXTD0t4D9z1ESnKM3-HpFabsE4tq3luCC7p-aXxcn.1.woff2` | 14812 | c87e948953bc90e38ba25d711f65377a62aef4e4a7cce272e1c6d8c315e4da41 |
| `notocoloremoji/v39/Yq6P-KqIXTD0t4D9z1ESnKM3-HpFabsE4tq3luCC7p-aXxcn.2.woff2` | 64244 | d500497beb107cb122df6b65452c8bd9699c9078b9ae5f35bb82696a8cce6f60 |
| `notocoloremoji/v39/Yq6P-KqIXTD0t4D9z1ESnKM3-HpFabsE4tq3luCC7p-aXxcn.3.woff2` | 164600 | 33d863891fc666d3bcd03700f344ef50da89cf005b10d0022b5d196ac18b3596 |
| `notocoloremoji/v39/Yq6P-KqIXTD0t4D9z1ESnKM3-HpFabsE4tq3luCC7p-aXxcn.4.woff2` | 99672 | f7848ab453b11441c20792f91c202ee98bcdcc223609e8cda6930d5f947c3d68 |
| `notocoloremoji/v39/Yq6P-KqIXTD0t4D9z1ESnKM3-HpFabsE4tq3luCC7p-aXxcn.5.woff2` | 118504 | 59ec028a34d2c3cb6e670d4fd231d7d61895b560738daa6ff4b956643ffe4aac |
| `notocoloremoji/v39/Yq6P-KqIXTD0t4D9z1ESnKM3-HpFabsE4tq3luCC7p-aXxcn.6.woff2` | 123212 | 732541f93fcf33bb4919aa42f865f242a1d3f3428fd68c659774ad8bdefd5c87 |
| `notocoloremoji/v39/Yq6P-KqIXTD0t4D9z1ESnKM3-HpFabsE4tq3luCC7p-aXxcn.7.woff2` | 210912 | d1f87d46c80af676a0099def081fffea41f85bc62dc0957405f2ff9a33f18c4d |
| `notocoloremoji/v39/Yq6P-KqIXTD0t4D9z1ESnKM3-HpFabsE4tq3luCC7p-aXxcn.8.woff2` | 414684 | 2583da22e236b9b53d85d7a9dcb3f18cb4bca92277ea26cf53ada69c63ac8278 |
| `notocoloremoji/v39/Yq6P-KqIXTD0t4D9z1ESnKM3-HpFabsE4tq3luCC7p-aXxcn.9.woff2` | 137732 | a50590a80ba6589388f4a51d463f853ef382dcbeb1e3b022dc6ed60147676ca2 |
| `notosanssymbols/v47/rP2up3q65FkAtHfwd-eIS2brbDN6gxP34F9jRRCe4W3gfQ8gb_VFRkzrbQ.woff2` | 69116 | 08202e258ea583254c036cff46a7077bb5af4f82c41a6c0a6775f6e44d99f1aa |
| `notosanssymbols2/v25/I_uyMoGduATTei9eI8daxVHDyfisHr71-gTBWXPM4Q.woff2` | 3576 | b0d885dae11e7fb260ce06cb94af4b7c865acbaf692b7f80eb23b0fb3d68153c |
| `notosanssymbols2/v25/I_uyMoGduATTei9eI8daxVHDyfisHr71-jrBWXPM4Q.woff2` | 5620 | 5824d50a6e4eca33bc2aca4fc61ceca9dd518bfe7d4b8c75adad3a8064d0d3a1 |
| `notosanssymbols2/v25/I_uyMoGduATTei9eI8daxVHDyfisHr71-pTgfA.woff2` | 15824 | 076185b66a4070d41cc0e52cdad03c00b30084a7438d3e52f2a47cf5e2d1eb01 |
| `notosanssymbols2/v25/I_uyMoGduATTei9eI8daxVHDyfisHr71-prgfE71.woff2` | 10124 | 97f469061805041dfda672e164eca7384f01e74ea1362a3aa91cf993be9a1579 |
| `notosanssymbols2/v25/I_uyMoGduATTei9eI8daxVHDyfisHr71-ujgfE71.woff2` | 12748 | 2eb49cfc40ca8a57d17e621471a4a2d583f7602676f583459f1dfc733fb94e1d |
| `notosanssymbols2/v25/I_uyMoGduATTei9eI8daxVHDyfisHr71-vrgfE71.woff2` | 382424 | 9c07d511848c274b5430c75bf98d1f2582680ef5f967947bfbdd06b75ca177c2 |
