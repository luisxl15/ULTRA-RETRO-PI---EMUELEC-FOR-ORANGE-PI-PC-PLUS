# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)

PKG_NAME="SDL_GameControllerDB"
PKG_VERSION="22a98f6339abf4b6ca6cb061443a70e4f7ab252d"
PKG_SHA256="20e4b3765f9bc6f409eecefbd7dbe6b5fc347d50fe6b2d68f576306ae4fca1dc"
PKG_LICENSE="OSS"
PKG_SITE="https://github.com/gabomdq/SDL_GameControllerDB"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET=""
PKG_LONGDESC="A community sourced database of game controller mappings to be used with SDL2 Game Controller functionality"
PKG_TOOLCHAIN="manual"

pre_configure_target() {
# These maps are old, we use our own
sed -i "s/19000000010000000100000001010000,odroid/# 19000000010000000100000001010000,odroid/g" gamecontrollerdb.txt
sed -i "s/19000000010000000200000011000000,odroid/# 19000000010000000200000011000000,odroid/g" gamecontrollerdb.txt
sed -i "s/03000000d11800000094000011010000,Google Stadia Controller/# 03000000d11800000094000011010000,Google Stadia Controller/g" gamecontrollerdb.txt
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/config/SDL-GameControllerDB
  cp $PKG_BUILD/gamecontrollerdb.txt $INSTALL/usr/config/SDL-GameControllerDB
}
