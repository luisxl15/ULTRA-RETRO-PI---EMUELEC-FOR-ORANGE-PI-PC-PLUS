# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="mupen64plus-nx-alt"
PKG_VERSION="15bada85906593376e8fd697f1b0b3af3a20f512"
PKG_SHA256="0b739581f2610fa6967891a657c749557fa4f7555d6a7e2e3475c9b397302b13"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/mupen64plus-libretro-nx"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain nasm:host $OPENGLES"
PKG_SECTION="libretro"
PKG_LONGDESC="Improved mupen64plus libretro core reimplementation"
PKG_TOOLCHAIN="make"
PKG_BUILD_FLAGS="-lto"


pre_configure_target() {
  sed -e "s|^GIT_VERSION ?.*$|GIT_VERSION := \" ${PKG_VERSION:0:7}\"|" -i Makefile


PKG_MAKE_OPTS_TARGET+=" platform=armv_neon_hardfloat FORCE_GLES=1"
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp mupen64plus_next_libretro.so $INSTALL/usr/lib/libretro/mupen64plus_next_alt_libretro.so
}
