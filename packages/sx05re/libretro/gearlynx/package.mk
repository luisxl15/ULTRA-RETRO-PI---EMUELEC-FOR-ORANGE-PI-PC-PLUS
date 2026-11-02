# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present Ultra Retro Pi

PKG_NAME="gearlynx"
PKG_VERSION="90e63bcee9f0df43dd352e51ab53f35f519e33d5"
PKG_SHA256="21b93010564c00d819b9e1b773470ace66318c566bb99984c0b8d0f811adc95e"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/drhelius/Gearlynx"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="libretro"
PKG_SHORTDESC="Accurate Atari Lynx core"
PKG_TOOLCHAIN="make"

make_target() {
  if [ "$ARCH" == "arm" ]; then
    make -C platforms/libretro platform=classic_armv7_a7
  else
    make -C platforms/libretro
  fi
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp platforms/libretro/gearlynx_libretro.so $INSTALL/usr/lib/libretro/
}
