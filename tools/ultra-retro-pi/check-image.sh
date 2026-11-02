#!/bin/bash
# confere no squashfs gerado se as mudanças do ULTRA RETRO PI estão na imagem
R=$HOME/Neo-EmuELEC-H3
SYS=$R/target/EmuELEC-H3.arm-4.5-opipcplus.system
U=unsquashfs
L=/tmp/system.list
$U -l -d "" $SYS > $L 2>/dev/null
echo "arquivos no sistema: $(wc -l < $L)"
chk() { grep -qE "$2" $L && echo "OK    $1" || echo "FALTA $1"; }
nochk() { grep -qE "$2" $L && echo "AINDA $1" || echo "OK    $1"; }
chk "overclock (batocera-overclock)"        '^/usr/bin/batocera/batocera-overclock$'
chk "versao URP (URP_VERSION)"              '^/usr/config/URP_VERSION$'
chk "tema ComicBook"                        '^/usr/config/emulationstation/themes/es-theme-ComicBook/'
chk "traducao pt_BR do ES (.po)"            'locale/pt_BR/LC_MESSAGES/emulationstation2.po$'
chk "Wi-Fi RTL8189FS (8189fs.conf)"         '8189fs.conf$'
chk "zram (zram-swap.service)"              'zram-swap.service$'
chk "fs-resize"                             '^/usr/lib/coreelec/fs-resize$|/fs-resize$'
chk "nucleo fake08"                         'fake08_libretro.so$'
chk "nucleo geargrafx"                      'geargrafx_libretro.so$'
chk "nucleo fbneo"                          'fbneo_libretro.so$'
chk "RetroArch"                             '^/usr/bin/retroarch$'
nochk "sem ports (/usr/bin/ports)"          '^/usr/bin/ports/'
nochk "sem flycast"                         'flycast'
nochk "sem PPSSPP"                          'PPSSPP|ppsspp'
nochk "sem mupen64plus"                     'mupen64plus'
# textos dentro de arquivos
$U -f -d /tmp/sq $SYS usr/config/URP_VERSION usr/bin/emulationstation usr/config/emulationstation/es_settings.cfg usr/config/emulationstation/es_systems.cfg >/dev/null 2>&1
echo "URP_VERSION = $(cat /tmp/sq/usr/config/URP_VERSION 2>/dev/null)"
grep -q "ULTRA RETRO PI" /tmp/sq/usr/bin/emulationstation && echo "OK    rodape 'ULTRA RETRO PI' no binario do ES" || echo "FALTA rodape no ES"
grep -q "SAFE SHUTDOWN" /tmp/sq/usr/bin/emulationstation && echo "OK    SAFE SHUTDOWN no ES" || echo "FALTA SAFE SHUTDOWN"
grep -q "SteamGridDB" /tmp/sq/usr/bin/emulationstation && echo "OK    scraper SteamGridDB no ES" || echo "FALTA SteamGridDB"
grep -o 'name="ThemeSet" value="[^"]*"' /tmp/sq/usr/config/emulationstation/es_settings.cfg
for s in dreamcast psp n64 ports; do grep -q "<name>$s</name>" /tmp/sq/usr/config/emulationstation/es_systems.cfg && echo "AINDA sistema $s no menu" || echo "OK    sistema $s escondido"; done
rm -rf /tmp/sq
