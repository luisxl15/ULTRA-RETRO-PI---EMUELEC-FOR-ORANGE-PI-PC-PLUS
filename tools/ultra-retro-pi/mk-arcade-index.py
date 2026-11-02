#!/usr/bin/env python3
"""Generates the compact ROM indexes used by auto_games_setup.sh from the cores' own DATs.

usage: mk-arcade-index.py <dat or xml> <out.idx.gz>

One line per set: name<TAB>cloneof<TAB>romof<TAB>status<TAB>crc,crc,...
The CRCs are the ROMs the set itself has to carry (no "merge" = not inherited from the
parent/BIOS, no "nodump"), so the check works for split, merged and non-merged sets.
status is the driver status ("good", "imperfect", "preliminary") when the DAT has one.
"""
import gzip
import sys
import xml.etree.ElementTree as ET

src, out = sys.argv[1], sys.argv[2]
n = 0
with gzip.open(out, 'wt', encoding='utf-8') as f:
    for _, el in ET.iterparse(src, events=('end',)):
        if el.tag not in ('game', 'machine'):
            continue
        if el.get('isbios') == 'yes' or el.get('isdevice') == 'yes':
            kind = 'bios'
        else:
            kind = ''
        crcs = []
        for rom in el.findall('rom'):
            if rom.get('merge') or rom.get('status') == 'nodump' or not rom.get('crc'):
                continue
            crcs.append(rom.get('crc').lower())
        drv = el.find('driver')
        status = drv.get('status', '') if drv is not None else ''
        if kind:
            status = kind
        f.write('\t'.join((el.get('name'), el.get('cloneof') or '', el.get('romof') or '',
                           status, ','.join(sorted(set(crcs))))) + '\n')
        n += 1
        el.clear()
print(out, n, 'sets')
