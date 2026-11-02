#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present Ultra Retro Pi

# Turns the GPIO controls (controllers wired to the board's pins) on or off and remembers the
# choice in emuelec.conf (ee_gpio.enabled, the same switch as SYSTEM SETTINGS > GPIO CONTROLS).

. /etc/profile

if [ ! -f /usr/lib/systemd/system/gpio.service ]; then
	MSG="Esta imagem nao tem o controlador GPIO."
elif [ "$(get_ee_setting ee_gpio.enabled)" == "1" ]; then
	set_ee_setting ee_gpio.enabled 0
	systemctl stop gpio
	MSG="GPIO DESATIVADO.\n\nOs controles ligados nos pinos da placa foram desligados."
else
	set_ee_setting ee_gpio.enabled 1
	systemctl start gpio
	sleep 2
	if systemctl is-active --quiet gpio; then
		MSG="GPIO ATIVADO.\n\nOs controles ligados nos pinos da placa ja funcionam e voltam a funcionar sozinhos a cada boot."
	else
		MSG="GPIO ATIVADO, mas o controlador nao subiu.\n\nVeja 'systemctl status gpio' ou envie os logs pelo Setup."
	fi
fi

printf "%b\n" "$MSG" > /tmp/gpio_controls.txt
text_viewer -t "GPIO" -f 24 /tmp/gpio_controls.txt
