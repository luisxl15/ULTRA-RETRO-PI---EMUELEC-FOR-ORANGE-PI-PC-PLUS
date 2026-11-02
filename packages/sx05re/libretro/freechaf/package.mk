# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present Ultra Retro Pi

PKG_NAME="freechaf"
PKG_VERSION="76c7a84f1f7e80f3e6f2bba96fe100cb24e99124"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/libretro/FreeChaF"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="libretro"
PKG_SHORTDESC="Fairchild Channel F core"
PKG_TOOLCHAIN="make"
PKG_MAKE_OPTS_TARGET="platform=unix"

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp $PKG_BUILD/freechaf_libretro.so $INSTALL/usr/lib/libretro/
}
