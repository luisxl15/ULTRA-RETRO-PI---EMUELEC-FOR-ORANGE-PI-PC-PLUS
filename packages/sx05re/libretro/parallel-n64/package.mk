# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="parallel-n64"
PKG_VERSION="acd5c9bc5d59a9d44acc03c921bb1f12728e9552"
PKG_SHA256="b0400af35e3674de1f9268e4d0331b6e436924b6f0a132759cf525a5cf32362b"
PKG_REV="2"
PKG_LICENSE="GPLv2"
PKG_ARCH="arm"
PKG_SITE="https://github.com/libretro/parallel-n64"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Optimized/rewritten Nintendo 64 emulator made specifically for Libretro. Originally based on Mupen64 Plus."
PKG_TOOLCHAIN="make"
PKG_BUILD_FLAGS="-lto"


if [[ "$ARCH" == "arm" ]]; then
	PKG_PATCH_DIRS="emuelec-arm32"
else
	PKG_PATCH_DIRS="emuelec-aarch64"
fi

pre_configure_target() {
PKG_MAKE_OPTS_TARGET=" platform=imx6 FORCE_GLES=1 ARCH=arm"
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp parallel_n64_libretro.so $INSTALL/usr/lib/libretro/parallel_n64_32b_libretro.so
  cp parallel_n64_libretro.so $INSTALL/usr/lib/libretro/parallel_n64_libretro.so
}
