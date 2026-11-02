#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present Ultra Retro Pi

# SAFE SHUTDOWN entry of the system carousel: flush everything to the card and power off
# through systemd, which stops EmulationStation and unmounts the partitions first.

sync
systemctl poweroff
