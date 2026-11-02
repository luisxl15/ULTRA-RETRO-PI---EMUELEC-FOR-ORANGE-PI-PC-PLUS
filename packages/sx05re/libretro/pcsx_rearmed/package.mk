# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="pcsx_rearmed"
PKG_VERSION="9f8b6f248e073f03c530efda7c4cc60a7e2ecafc" # r26l
PKG_SHA256="5760a1ab5fc57ad78462c96e2923a99c5aaf06c97f61aafe7b11df086897edf2"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/pcsx_rearmed"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain alsa"
PKG_SHORTDESC="ARM optimized PCSX fork"
PKG_TOOLCHAIN="make"
PKG_BUILD_FLAGS="+speed -gold"

make_target() {
cd ${PKG_BUILD}
export ALLOW_LIGHTREC_ON_ARM=1
# libchdr's bundled lzma CpuArch.c needs the arm32 HWCAP2 bits, which the 3.4 kernel
# headers predate (values from the kernel's uapi asm/hwcap.h; 3.4 reports them as absent)
[ "${ARCH}" == "arm" ] && export CFLAGS="${CFLAGS} -DHWCAP2_AES=1 -DHWCAP2_PMULL=2 -DHWCAP2_SHA1=4 -DHWCAP2_SHA2=8 -DHWCAP2_CRC32=16"
make -f Makefile.libretro GIT_VERSION=${PKG_VERSION} platform=classic_armv7_a7
}

makeinstall_target() {
INSTALLTO="/usr/lib/libretro"
mkdir -p ${INSTALL}${INSTALLTO}/

if [ "${ARCH}" == "arm" ]; then
    cp pcsx_rearmed_libretro.so ${INSTALL}${INSTALLTO}/pcsx_rearmed_32b_libretro.so
	cp pcsx_rearmed_libretro.so ${INSTALL}${INSTALLTO}/pcsx_rearmed_libretro.so
else
    cp pcsx_rearmed_libretro.so ${INSTALL}${INSTALLTO}
fi
}
