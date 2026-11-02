#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present Ultra Retro Pi
"""AUTO GAMES SETUP: picks, game by game, the arcade core whose ROM set matches the zip.

For every .zip in the arcade folders it compares the CRCs inside with the sets FBNeo and
MAME 2003-Plus expect (indexes built from the cores' own DATs, see
tools/ultra-retro-pi/mk-arcade-index.py). FBNeo comes first: lighter on the H3 Cortex-A7,
less input lag, run-ahead. The choice is written to emuelec.conf the same way the ES game
options menu does it (system["file.zip"].emulator/.core), so it can still be changed there.

usage: ultraretropi-autosetup.py [--dry-run] [--roms DIR] [--conf FILE] [--es-systems FILE]
                                 [--index-dir DIR] [--report FILE]
"""
import argparse
import gzip
import os
import shutil
import sys
import xml.etree.ElementTree as ET
import zipfile

ARCADE_SYSTEMS = ('arcade', 'mame', 'fbn', 'fbneo', 'neogeo', 'cps1', 'cps2', 'cps3')
CORE_ORDER = ('fbneo', 'mame2003_plus')
CORE_LABEL = {'fbneo': 'FBNeo', 'mame2003_plus': 'MAME 2003-Plus'}
BAD_STATUS = ('preliminary', 'protection')

ap = argparse.ArgumentParser()
ap.add_argument('--dry-run', action='store_true')
ap.add_argument('--roms', default='/storage/roms')
ap.add_argument('--conf', default='/storage/.config/emuelec/configs/emuelec.conf')
ap.add_argument('--es-systems', default='/storage/.config/emulationstation/es_systems.cfg')
ap.add_argument('--index-dir', default='/usr/share/ultraretropi/autosetup')
ap.add_argument('--report', default='/tmp/auto_games_setup.txt')
args = ap.parse_args()


def load_index(core):
    idx = {}
    path = os.path.join(args.index_dir, core + '.idx.gz')
    with gzip.open(path, 'rt', encoding='utf-8') as f:
        for line in f:
            name, cloneof, romof, status, crcs = line.rstrip('\n').split('\t')
            idx[name] = (cloneof, romof, status, set(crcs.split(',')) if crcs else set())
    return idx


def arcade_systems():
    """(system name, rom folder, libretro cores it accepts) from es_systems.cfg"""
    cfg = args.es_systems
    if not os.path.exists(cfg):
        cfg = '/usr/config/emulationstation/es_systems.cfg'
    out = []
    for system in ET.parse(cfg).getroot().findall('system'):
        name = (system.findtext('name') or '').strip()
        if name not in ARCADE_SYSTEMS:
            continue
        path = (system.findtext('path') or '').strip().replace('/storage/roms', args.roms, 1)
        cores = set()
        for emu in system.iter('emulator'):
            if emu.get('name') == 'libretro':
                cores |= {(c.text or '').strip() for c in emu.iter('core')}
        out.append((name, path, cores & set(CORE_ORDER)))
    return out


def conf_key(system, filename):
    # same as FileData::getConfigurationName() in ES
    return '%s["%s"]' % (system, filename.replace('=', '').replace('#', ''))


indexes = {c: load_index(c) for c in CORE_ORDER}
bios_names = {n for idx in indexes.values() for n, v in idx.items() if v[2] == 'bios'} | {'neogeo'}

assign = {}                 # conf key -> core
count = {c: 0 for c in CORE_ORDER}
no_match, warnings, skipped_7z = [], [], 0
parent_checks = []          # (system, zip, core, parent) for clones that need the parent zip

for system, folder, cores in arcade_systems():
    if not cores or not os.path.isdir(folder):
        continue
    zips = sorted(f for f in os.listdir(folder) if f.lower().endswith('.zip'))
    present = {os.path.splitext(f)[0].lower() for f in zips}
    skipped_7z += sum(1 for f in os.listdir(folder) if f.lower().endswith('.7z'))
    for fn in zips:
        game = os.path.splitext(fn)[0].lower()
        if game in bios_names:
            continue
        try:
            with zipfile.ZipFile(os.path.join(folder, fn)) as z:
                have = {'%08x' % i.CRC for i in z.infolist() if not i.is_dir()}
        except (zipfile.BadZipFile, OSError):
            no_match.append('%s/%s: zip corrompido' % (system, fn))
            continue

        chosen, why_not = None, []
        for core in CORE_ORDER:
            if core not in cores:
                continue
            entry = indexes[core].get(game)
            if entry is None:
                continue
            cloneof, romof, status, need = entry
            missing = need - have
            if missing:
                why_not.append('%s: faltam %d de %d arquivos' % (CORE_LABEL[core], len(missing), len(need)))
                continue
            if status in BAD_STATUS:
                why_not.append('%s: driver "%s" (nao roda direito)' % (CORE_LABEL[core], status))
                continue
            chosen = core
            # a clone in a split set also needs a working parent zip (checked after the loop,
            # once we know whether the parent matched); every set needs its BIOS
            if cloneof:
                parent_need = indexes[core].get(cloneof, ('', '', '', set()))[3]
                if parent_need - have:
                    parent_checks.append((system, fn, core, cloneof))
            bios = romof if romof and romof != cloneof else ''
            if bios and bios not in present and not os.path.exists(os.path.join(args.roms, 'bios', bios + '.zip')):
                warnings.append('%s/%s: falta a BIOS %s.zip' % (system, fn, bios))
            if status == 'imperfect':
                warnings.append('%s/%s: emulacao imperfeita no %s' % (system, fn, CORE_LABEL[core]))
            break

        if chosen:
            assign[conf_key(system, fn)] = chosen
            count[chosen] += 1
        else:
            known = any(game in indexes[c] for c in CORE_ORDER)
            reason = '; '.join(why_not) if why_not else ('nenhum nucleo deste sistema conhece o jogo'
                                                         if not known else 'sem nucleo compativel neste sistema')
            no_match.append('%s/%s: %s' % (system, fn, reason))

for system, fn, core, parent in parent_checks:
    if assign.get(conf_key(system, parent + '.zip')) != core:
        warnings.append('%s/%s: o jogo pai %s.zip falta ou nao bate com o %s'
                        % (system, fn, parent, CORE_LABEL[core]))

# ---- write emuelec.conf (keeps every other line) ----
if assign and not args.dry_run:
    lines = []
    if os.path.exists(args.conf):
        shutil.copy2(args.conf, args.conf + '.bak-autosetup')
        with open(args.conf, encoding='utf-8', errors='surrogateescape') as f:
            lines = f.read().splitlines()
    ours = {k + suffix for k in assign for suffix in ('.core=', '.emulator=')}
    lines = [l for l in lines if not any(l.startswith(p) for p in ours)]
    for k in sorted(assign):
        lines.append('%s.emulator=libretro' % k)
        lines.append('%s.core=%s' % (k, assign[k]))
    tmp = args.conf + '.tmp'
    with open(tmp, 'w', encoding='utf-8', errors='surrogateescape') as f:
        f.write('\n'.join(lines) + '\n')
    os.replace(tmp, args.conf)

# ---- report ----
r = ['AUTO GAMES SETUP - ARCADE', '']
total = sum(count.values())
r.append('%d jogos configurados:' % total)
for c in CORE_ORDER:
    r.append('  %-16s %d' % (CORE_LABEL[c], count[c]))
if skipped_7z:
    r.append('  (%d arquivos .7z nao verificados: use .zip para o ajuste automatico)' % skipped_7z)
r.append('')
if no_match:
    r.append('%d jogos SEM ROMset compativel (troque pelo ROMset do FBNeo ou do MAME 2003-Plus):' % len(no_match))
    r += ['  ' + x for x in no_match]
    r.append('')
if warnings:
    r.append('Avisos:')
    r += ['  ' + x for x in warnings]
    r.append('')
if total == 0 and not no_match:
    r.append('Nenhuma ROM de arcade (.zip) encontrada em arcade, mame, fbneo, neogeo ou cps1/2/3.')
r.append('Os outros sistemas ja usam os nucleos mais leves para a H3 (ex.: SNES Snes9x 2010,')
r.append('Mega Drive PicoDrive, GBA gpSP, Master System Gearsystem, PS1 PCSX ReARMed).')
r.append('Para mudar um jogo: segure A sobre ele > OPCOES AVANCADAS DO JOGO > NUCLEO.')
if args.dry_run:
    r.append('')
    r.append('(simulacao: nada foi gravado)')
with open(args.report, 'w', encoding='utf-8') as f:
    f.write('\n'.join(r) + '\n')
print('\n'.join(r))
sys.exit(0)
