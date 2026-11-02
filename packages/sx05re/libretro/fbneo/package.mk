# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="fbneo"
PKG_VERSION="9d82650bb9591966987a4c36ae8a1409ce0d5d68"
PKG_SHA256="671498c5a0cbcfac28a69427800a7f679ad68002da705bbf5e8d5a5ab7ef33ba"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="Non-commercial"
PKG_SITE="https://github.com/libretro/FBNeo"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="libretro"
PKG_SHORTDESC="Port of Final Burn Neo to Libretro."
PKG_LONGDESC="Currently, FB neo supports games on Capcom CPS-1 and CPS-2 hardware, SNK Neo-Geo hardware, Toaplan hardware, Cave hardware, and various games on miscellaneous hardware. "
PKG_TOOLCHAIN="make"


pre_configure_target() {
# upstream now ships a meson.build, so the build runs from .$TARGET_NAME: use absolute paths
sed -i "s|LDFLAGS += -static-libgcc -static-libstdc++|LDFLAGS += -static-libgcc|"  $PKG_BUILD/src/burner/libretro/Makefile

# USE_EXPERIMENTAL_FLAGS=0: that block adds whole-program LTO, whose WPA stage alone gets
# lto1 OOM-killed on a 6 GB build box (even with -flto=1); -fwhole-program can't stay
# without LTO, so the block goes as a whole
PKG_MAKE_OPTS_TARGET=" -C $PKG_BUILD/src/burner/libretro USE_CYCLONE=0 profile=performance USE_EXPERIMENTAL_FLAGS=0"
# epic12 uses threads/semaphores and the classic_armv7_a7 target never links libpthread;
# -pthread (not -lpthread) so gcc appends it after the objects, past -Wl,--as-needed
export LDFLAGS="$LDFLAGS -pthread"

if [[ "$TARGET_FPU" =~ "neon" ]]; then
	PKG_MAKE_OPTS_TARGET+=" HAVE_NEON=1"
fi

	if [ "$ARCH" == "arm" ]; then
	PKG_MAKE_OPTS_TARGET+=" platform=classic_armv7_a7 "
	# the bundled lib7z CpuArch.c needs the arm32 HWCAP2 bits, which the 3.4 kernel
	# headers predate (values from the kernel's uapi asm/hwcap.h; 3.4 reports them as absent)
	export CFLAGS="$CFLAGS -DHWCAP2_AES=1 -DHWCAP2_PMULL=2 -DHWCAP2_SHA1=4 -DHWCAP2_SHA2=8 -DHWCAP2_CRC32=16"
	fi

}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp $PKG_BUILD/src/burner/libretro/fbneo_libretro.so $INSTALL/usr/lib/libretro/
}
