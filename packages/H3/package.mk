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
}
