# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="RTL8192DU"
PKG_VERSION="72b53f8a6c2a6696d60791df4455c3073fffc4e4"
PKG_SHA256="dec3cc45601c2c6dab47816523cb5a5731393d34cc75ec0f96a91191d3563fdd"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/lwfinger/rtl8192du"
PKG_URL="https://github.com/lwfinger/rtl8192du/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="$LINUX_DEPENDS"
PKG_LONGDESC="Realtek RTL8192DU Linux 3.x driver"
PKG_IS_KERNEL_PKG="yes"


if [ "$PROJECT" = "H3" ]; then
PKG_VERSION="9e7eb15"
PKG_SITE="https://github.com/lwfinger/rtl8192du"
PKG_URL="https://github.com/lwfinger/rtl8192du/archive/$PKG_VERSION.tar.gz"
PKG_SOURCE_DIR="rtl8192du-$PKG_VERSION*"
#PKG_SHA256="aa386479291fff3e9fe341d5a682b692a7a098d833be5eaa718e1b6ecfd8e167"
PKG_SHA256="ce0d2bc2406c9ea28b27c54b92e9cbdf618b35d117467d7e133c49963457d0cc"
fi
PKG_PATCH_DIRS="${PROJECT}"
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
