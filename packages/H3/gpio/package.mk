# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Matthew Wang(https://github.com/asakous)

PKG_NAME="gpio"
PKG_VERSION="5ef1c0debf38ffd93ec806d4958c0c47ee61ee9a"
PKG_ARCH="any"
PKG_LICENSE="GPL3"
PKG_SITE="https://github.com/asakous/RetrOrangePi_gpio"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain uinput python-evdev dialog pyudev python2-evdev"
PKG_SHORTDESC="gpio."
PKG_LONGDESC="gpio."
PKG_TOOLCHAIN="manual"
GET_HANDLER_SUPPORT="git"
			
pre_make_target() {
  export PYTHONXCPREFIX="$SYSROOT_PREFIX/usr"
  export LDSHARED="$CC -shared"
}

makeinstall_target() {
  python3 setup.py install --root=$INSTALL --prefix=/usr
  mkdir -p $INSTALL/usr/config/
  cp -rf $PKG_DIR/config/* $INSTALL/usr/config/
}
