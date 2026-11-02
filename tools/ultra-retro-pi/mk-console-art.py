#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present Ultra Retro Pi
"""Console art for the ComicBook system view: the console's 16-bit pixel art, scaled 2x
without smoothing, with a thick black outline and a hard shadow, popping out of a yellow
"POW" burst in the bottom-right corner.

Sprites: Pixel-Metadata theme by Eric Hettervik (github.com/ehettervik/es-theme-pixel-metadata,
"Feel free to modify this theme or use graphics in other projects"), pinned to SPRITES_COMMIT.

Writes <out>/<theme folder>/art/console.png. Every image is the same bottom-right box of a
1280x720 screen (the union of all of them), so the es-theme-ComicBook package.mk places them
all with pos/origin 1 1 and the one size printed at the end.

usage: mk-console-art.py <out dir> [--cache DIR]
"""
import argparse
import math
import os
import tempfile
import urllib.request

from PIL import Image, ImageChops, ImageDraw, ImageFilter

SPRITES_COMMIT = 'dd9d6eb3257acbd2a9dcfbebb7f6eb6617fc2428'
SPRITES_URL = 'https://raw.githubusercontent.com/ehettervik/es-theme-pixel-metadata/%s/%s/console.png'
W, H = 1280, 720
SCALE = 2

# ComicBook theme folder (the <theme> of each es_systems entry) -> Pixel-Metadata folder.
# Only the same console (or a hack/MSU collection of it); systems with no console of their
# own are left without art.
SPRITE_FOR = {t: t for t in (
    '3do amiga amstradcpc arcade atari2600 atari5200 atari7800 atari800 atarilynx atarist '
    'channelf colecovision c64 daphne famicom fds gameandwatch gamegear gb gba gbc gc genesis '
    'intellivision mame mastersystem megadrive msx nes neogeo ngp ngpc odyssey2 pc pce-cd pcengine '
    'pcfx psx saturn scummvm sega32x segacd sfc sg-1000 snes supergrafx tg16 vectrex '
    'videopac virtualboy wii wonderswan wonderswancolor zxspectrum').split()}
SPRITE_FOR.update({
    'cps1': 'arcade', 'cps2': 'arcade', 'cps3': 'arcade', 'fbn': 'arcade',
    'msx2': 'msx', 'tg16cd': 'tg-cd', 'nesh': 'nes', 'gbh': 'gb', 'gbah': 'gba', 'gbch': 'gbc',
    'snesh': 'snes', 'snesmsu1': 'snes', 'ggh': 'gamegear', 'genh': 'genesis',
    'megadrivemsu': 'megadrive', 'megadrive-japan': 'megadrive',
})


def sprite(cache, name):
    path = os.path.join(cache, name + '.png')
    if not os.path.exists(path):
        os.makedirs(cache, exist_ok=True)
        urllib.request.urlretrieve(SPRITES_URL % (SPRITES_COMMIT, name), path)
    return Image.open(path).convert('RGBA')


def sticker(im, outline=4, shadow=8):
    s = im.resize((im.width * SCALE, im.height * SCALE), Image.NEAREST)
    pad = outline + shadow + 2
    out = Image.new('RGBA', (s.width + 2 * pad, s.height + 2 * pad), (0, 0, 0, 0))
    a = Image.new('L', out.size, 0)
    a.paste(s.split()[3], (pad, pad))
    fat = a.filter(ImageFilter.MaxFilter(outline * 2 + 1))
    out.paste(Image.new('RGBA', out.size, (0, 0, 0, 120)), (shadow, shadow), fat)
    out.paste(Image.new('RGBA', out.size, (0, 0, 0, 255)), (0, 0), fat)
    out.alpha_composite(s, (pad, pad))
    return out


def burst(w, h, points=14):
    im = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    cx, cy = w / 2, h / 2
    pts = []
    for i in range(points * 2):
        r = 0.98 if i % 2 == 0 else 0.70
        ang = math.pi * i / points
        pts.append((cx + math.cos(ang) * r * w / 2, cy + math.sin(ang) * r * h / 2))
    inner = [(cx + (x - cx) * 0.93, cy + (y - cy) * 0.93) for x, y in pts]
    d = ImageDraw.Draw(im)
    d.polygon(pts, fill=(0, 0, 0, 255))
    d.polygon(inner, fill=(255, 214, 0, 255))
    # halftone dots, like the rest of the theme
    dots = Image.new('L', (w, h), 0)
    dd = ImageDraw.Draw(dots)
    for y in range(0, h, 9):
        for x in range((y // 9 % 2) * 4, w, 9):
            dd.ellipse((x, y, x + 3, y + 3), fill=70)
    mask = Image.new('L', (w, h), 0)
    ImageDraw.Draw(mask).polygon(inner, fill=255)
    im.paste((255, 120, 0, 255), (0, 0), ImageChops.multiply(dots, mask))
    return im


def screen(im):
    st = sticker(im)
    b = burst(int(st.width * 1.6), int(st.height * 1.55))
    cx, cy = W - 175, H - 118
    screen = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    screen.alpha_composite(b, (cx - b.width // 2 + 30, cy - b.height // 2 + 22))   # bleeds off the page
    screen.alpha_composite(st, (cx - st.width // 2, cy - st.height // 2))
    return screen


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('out')
    ap.add_argument('--cache', default=os.path.join(tempfile.gettempdir(), 'pixel-metadata-' + SPRITES_COMMIT[:7]))
    args = ap.parse_args()
    screens = {src: screen(sprite(args.cache, src)) for src in sorted(set(SPRITE_FOR.values()))}
    x0 = min(s.getbbox()[0] for s in screens.values())
    y0 = min(s.getbbox()[1] for s in screens.values())
    for folder, src in sorted(SPRITE_FOR.items()):
        art = os.path.join(args.out, folder, 'art')
        os.makedirs(art, exist_ok=True)
        screens[src].crop((x0, y0, W, H)).save(os.path.join(art, 'console.png'), optimize=True)
    print('%d systems, %d sprites, box %dx%d -> <size>%.4f %.4f</size>'
          % (len(SPRITE_FOR), len(screens), W - x0, H - y0, (W - x0) / W, (H - y0) / H))


if __name__ == '__main__':
    main()
