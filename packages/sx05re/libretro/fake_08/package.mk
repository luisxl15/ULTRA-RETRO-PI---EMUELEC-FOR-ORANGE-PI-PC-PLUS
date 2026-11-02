# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present Ultra Retro Pi

PKG_NAME="fake_08"
PKG_VERSION="814991a2571ad3970e386cef48f3b148aa1c27b9"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/jtothebell/fake-08"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="libretro"
PKG_SHORTDESC="PICO-8 player that doesn't need the official binary"
PKG_TOOLCHAIN="make"

pre_configure_target() {
  PKG_MAKE_OPTS_TARGET="-C $PKG_BUILD/platform/libretro platform=unix"
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp $PKG_BUILD/platform/libretro/fake08_libretro.so $INSTALL/usr/lib/libretro/
}
