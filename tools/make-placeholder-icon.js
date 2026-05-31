#!/usr/bin/env node
// Generates a 1024x1024 placeholder app icon (PNG) for Calos.
// Pure Node (zlib) — no native image deps. Buddy's real art replaces icon.png.
// Run: node tools/make-placeholder-icon.js Assets.xcassets/AppIcon.appiconset/icon.png
const zlib = require("zlib");
const fs = require("fs");

const S = 1024;
const out = process.argv[2] || "icon.png";
// RGB (no alpha) — watchOS/iOS app icons must NOT have an alpha channel.
const buf = Buffer.alloc(S * S * 3);

function set(x, y, r, g, b) {
  const i = (y * S + x) * 3;
  buf[i] = r; buf[i + 1] = g; buf[i + 2] = b;
}
const cx = S / 2, cy = S / 2;
for (let y = 0; y < S; y++) {
  for (let x = 0; x < S; x++) {
    // warm diagonal gradient background (orange -> red)
    const t = (x + y) / (2 * S);
    let r = Math.round(244 - t * 80);
    let g = Math.round(162 - t * 110);
    let b = Math.round(89 - t * 60);
    const dx = x - cx, dy = y - cy;
    const d = Math.sqrt(dx * dx + dy * dy);
    // white "plate" ring
    if (d > 300 && d < 360) { r = g = b = 250; }
    // inner cream disc
    else if (d <= 300) { r = 255; g = 245; b = 224; }
    // a single red pepperoni-ish dot, off-center (placeholder personality)
    const pd = Math.sqrt((x - cx + 70) ** 2 + (y - cy - 40) ** 2);
    if (pd < 70) { r = 193; g = 57; b = 43; }
    const pd2 = Math.sqrt((x - cx - 90) ** 2 + (y - cy + 80) ** 2);
    if (pd2 < 55) { r = 193; g = 57; b = 43; }
    set(x, y, r, g, b);
  }
}

// PNG encode: truecolor (no alpha), filter byte 0 per scanline
const raw = Buffer.alloc(S * (S * 3 + 1));
for (let y = 0; y < S; y++) {
  raw[y * (S * 3 + 1)] = 0;
  buf.copy(raw, y * (S * 3 + 1) + 1, y * S * 3, (y + 1) * S * 3);
}
function chunk(type, data) {
  const len = Buffer.alloc(4); len.writeUInt32BE(data.length);
  const t = Buffer.from(type);
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(Buffer.concat([t, data])) >>> 0);
  return Buffer.concat([len, t, data, crc]);
}
const crcTable = (() => {
  const tbl = [];
  for (let n = 0; n < 256; n++) {
    let c = n;
    for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
    tbl[n] = c >>> 0;
  }
  return tbl;
})();
function crc32(b) {
  let c = 0xffffffff;
  for (let i = 0; i < b.length; i++) c = crcTable[(c ^ b[i]) & 0xff] ^ (c >>> 8);
  return c ^ 0xffffffff;
}
const sig = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
const ihdr = Buffer.alloc(13);
ihdr.writeUInt32BE(S, 0); ihdr.writeUInt32BE(S, 4);
ihdr[8] = 8; ihdr[9] = 2; // 8-bit, RGB (truecolor, no alpha)
const idat = zlib.deflateSync(raw, { level: 9 });
const png = Buffer.concat([
  sig, chunk("IHDR", ihdr), chunk("IDAT", idat), chunk("IEND", Buffer.alloc(0)),
]);
fs.writeFileSync(out, png);
console.log(`wrote ${out} (${png.length} bytes, ${S}x${S})`);
