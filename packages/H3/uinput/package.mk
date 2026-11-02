# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Matthew Wang(https://github.com/asakous)

PKG_NAME="uinput"
PKG_VERSION="befe94a1199a0acc556035ca544bea4b429c20f4"
PKG_ARCH="any"
PKG_LICENSE="GPL3"
PKG_SITE="https://github.com/tuomasjjrasanen/python-uinput"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_SHORTDESC="uinput."
PKG_LONGDESC="uinput."
PKG_TOOLCHAIN="manual"
GET_HANDLER_SUPPORT="git"
			
pre_make_target() {
  export PYTHONXCPREFIX="$SYSROOT_PREFIX/usr"
  export LDSHARED="$CC -shared"
}

makeinstall_target() {
  python setup.py install --root=$INSTALL --prefix=/usr
}
