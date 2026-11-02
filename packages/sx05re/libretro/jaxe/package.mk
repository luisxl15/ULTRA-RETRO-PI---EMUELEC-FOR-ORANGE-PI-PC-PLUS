# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present Ultra Retro Pi

PKG_NAME="jaxe"
PKG_VERSION="c767afd785e01a15bcd575a2d93b737add82b675"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/kurtjd/jaxe"
PKG_URL="$PKG_SITE.git"
PKG_GIT_CLONE_BRANCH="main"
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="libretro"
PKG_SHORTDESC="CHIP-8 / S-CHIP / XO-CHIP core"
PKG_TOOLCHAIN="make"

make_target() {
  # the repo also has a CMakeLists.txt, so the build runs from .$TARGET_NAME
  make -C $PKG_BUILD -f Makefile.libretro CC="$CC" CXX="$CXX" AR="$AR" platform=unix
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp $PKG_BUILD/jaxe_libretro.so $INSTALL/usr/lib/libretro/
}
