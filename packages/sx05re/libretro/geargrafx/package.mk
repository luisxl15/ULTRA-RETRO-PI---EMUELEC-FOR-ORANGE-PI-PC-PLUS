# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present Ultra Retro Pi

PKG_NAME="geargrafx"
PKG_VERSION="13997bf9ff7adfa53b1b0079a301892d0d40917b"
PKG_SHA256="a466e3195d9c48c8c44302f6934c863362262e6d2a7a2a7fecb930ba898dfc68"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/drhelius/Geargrafx"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="libretro"
PKG_SHORTDESC="Accurate PC Engine / TurboGrafx core"
PKG_TOOLCHAIN="make"

make_target() {
  if [ "$ARCH" == "arm" ]; then
    # the bundled lzma CpuArch.c needs the arm32 HWCAP2 bits, which the 3.4 kernel
    # headers predate; values from the kernel's uapi asm/hwcap.h. getauxval(AT_HWCAP2)
    # returns 0 on 3.4, so these features are correctly reported as absent.
    export CFLAGS="$CFLAGS -DHWCAP2_AES=1 -DHWCAP2_PMULL=2 -DHWCAP2_SHA1=4 -DHWCAP2_SHA2=8 -DHWCAP2_CRC32=16"
    make -C platforms/libretro platform=classic_armv7_a7
  else
    make -C platforms/libretro
  fi
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp platforms/libretro/geargrafx_libretro.so $INSTALL/usr/lib/libretro/
}
