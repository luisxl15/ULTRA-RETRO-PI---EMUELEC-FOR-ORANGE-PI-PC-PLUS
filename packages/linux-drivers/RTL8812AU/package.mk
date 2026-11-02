# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="RTL8812AU"
PKG_VERSION="d88d8b2e2a1b33ebdd62b8a5de307b37c39d8477"
PKG_SHA256="c5b2fcc6cbf6901e63f75ece49a8ce3219004536cfc585b9815b34d943c9f311"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/MilhouseVH/RTL8812AU"
PKG_URL="https://github.com/MilhouseVH/RTL8812AU/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="$LINUX_DEPENDS"
PKG_LONGDESC="Realtek RTL8812AU Linux 3.x driver"
PKG_IS_KERNEL_PKG="yes"

if [ "$PROJECT" = "H3" ]; then
PKG_PATCH_DIRS="patches_h3"
PKG_VERSION="4.3.20"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/Grawp/rtl8812au_rtl8821au"
PKG_URL="https://github.com/Grawp/rtl8812au_rtl8821au/archive/$PKG_VERSION.tar.gz"
PKG_SOURCE_DIR="rtl8812au_rtl8821au-$PKG_VERSION"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="$LINUX_DEPENDS"
PKG_SECTION="driver"
PKG_SHORTDESC="Realtek RTL8812AU Linux 3.x driver"
PKG_LONGDESC="Realtek RTL8812AU Linux 3.x driver"
PKG_IS_ADDON="no"
PKG_AUTORECONF="no"
PKG_SHA256="04f458b14114bcb9d12f9d353c55fddaa93a89e6f7a294563413ed4630c25409"
fi
pre_make_target() {
  unset LDFLAGS
}

make_target() {
  make V=1 \
       ARCH=$TARGET_KERNEL_ARCH \
       KSRC=$(kernel_path) \
       CROSS_COMPILE=$TARGET_KERNEL_PREFIX \
       CONFIG_POWER_SAVING=n
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/modules/3.4.113/$PKG_NAME
    cp *.ko $INSTALL/usr/lib/modules/3.4.113/$PKG_NAME
}
