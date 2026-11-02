# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present Ultra Retro Pi

PKG_NAME="lowresnx"
PKG_VERSION="63d5988f74e1eea2ecd6ea0445a8ce260b0a9822"
PKG_SHA256="17622db857bf41076c3bd33c6428c0922de3f1944f125f939cc9c3a6ebf5cf33"
PKG_LICENSE="Zlib"
PKG_SITE="https://github.com/timoinutilis/lowres-nx"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="libretro"
PKG_SHORTDESC="LowRes NX fantasy console (BASIC)"
PKG_TOOLCHAIN="make"

make_target() {
  make -C platform/LibRetro platform=unix
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp platform/LibRetro/lowresnx_libretro.so $INSTALL/usr/lib/libretro/
}
