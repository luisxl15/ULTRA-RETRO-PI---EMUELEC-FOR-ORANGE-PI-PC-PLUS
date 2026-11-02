# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="H3"
PKG_VERSION=""
PKG_LICENSE="various"
PKG_SITE=""
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain"
PKG_SHORTDESC="EmuELEC tools metapackage"
PKG_SECTION="virtual"

PKG_DEPENDS_TARGET+=" zc210-libretro wpa_supplicant gobject-introspection dbus-python3"


post_install() {
  enable_service zram-swap.service

  # ES shows System settings > Overclock only when this script exists
  mkdir -p $INSTALL/usr/bin/batocera
  cp $PKG_DIR/scripts/batocera-overclock $INSTALL/usr/bin/batocera/
  chmod +x $INSTALL/usr/bin/batocera/batocera-overclock
  enable_service cpu-overclock.service

  # AUTO GAMES SETUP (Setup > Auto Games Setup): arcade core per game from the ROM set.
  # The indexes come from the cores' DATs: tools/ultra-retro-pi/mk-arcade-index.py
  cp $PKG_DIR/autosetup/ultraretropi-autosetup.py $INSTALL/usr/bin/
  chmod +x $INSTALL/usr/bin/ultraretropi-autosetup.py
  mkdir -p $INSTALL/usr/share/ultraretropi/autosetup
  cp $PKG_DIR/autosetup/*.idx.gz $INSTALL/usr/share/ultraretropi/autosetup/
}
