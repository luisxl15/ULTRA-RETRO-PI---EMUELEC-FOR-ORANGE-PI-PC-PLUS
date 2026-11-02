#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present Ultra Retro Pi

# AUTO GAMES SETUP: picks the arcade core game by game from the ROM set inside each zip
# (FBNeo first, MAME 2003-Plus when only its set matches), shows the report and restarts
# EmulationStation so it loads the new per-game cores.

. /etc/profile

if [ ! -x /usr/bin/ultraretropi-autosetup.py ]; then
	echo "Esta imagem nao tem o Auto Games Setup." > /tmp/auto_games_setup.txt
	text_viewer -t "AUTO GAMES SETUP" -f 24 /tmp/auto_games_setup.txt
	exit 0
fi

echo "Verificando as ROMs de arcade, aguarde..." > /tmp/auto_games_setup.txt
/usr/bin/python3 /usr/bin/ultraretropi-autosetup.py > /dev/null 2>> /emuelec/logs/emuelec.log \
	|| echo "Falhou: veja /emuelec/logs/emuelec.log" >> /tmp/auto_games_setup.txt
sync
text_viewer -t "AUTO GAMES SETUP" -f 20 /tmp/auto_games_setup.txt

# ES only reads emuelec.conf at startup
systemctl restart emustation
