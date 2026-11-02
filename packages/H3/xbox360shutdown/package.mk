# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="xbox360shutdown"
PKG_VERSION="c0d560967c0a685f2863b7185fcc54d730390d08"
PKG_LICENSE="OSS"
PKG_SITE="https://github.com/spleen1981/xbox360-controllers-shutdown"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain SDL2-git"
PKG_LONGDESC="Test joystick with SDL2 in Linux"
PKG_TOOLCHAIN="make"
GET_HANDLER_SUPPORT="git"

#pre_configure_target() {
#sed -i "s|gcc|${CC}|" Makefile
#}

makeinstall_target() {
mkdir -p $INSTALL/usr/bin
cp -rf xbox360-controllers-shutdown $INSTALL/usr/bin
}
