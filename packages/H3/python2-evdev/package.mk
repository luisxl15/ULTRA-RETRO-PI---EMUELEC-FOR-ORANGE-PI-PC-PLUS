# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 0riginally created by Escalade (https://github.com/escalade)
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)

PKG_NAME="python2-evdev"
PKG_VERSION="5adc2abf1ec8a02c05c80cb1b3e34ba1d4237803"
PKG_LICENSE="OSS"
PKG_SITE="https://github.com/gvalkov/python-evdev"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain Python3:host Python3 distutilscross:host"
PKG_LONGDESC="Userspace evdev events"
PKG_TOOLCHAIN="manual"

pre_make_target() {
  export PYTHONXCPREFIX="${SYSROOT_PREFIX}/usr"
  export LDFLAGS="${LDFLAGS} -L${SYSROOT_PREFIX}/usr/lib -L${SYSROOT_PREFIX}/lib"
  export LDSHARED="${CC} -shared"
  find . -name setup.py -exec sed -i "s:/usr/include/linux/input.h :${SYSROOT_PREFIX}/usr/include/linux/input.h:g" \{} \;
  find . -name setup.py -exec sed -i "s:/usr/include/linux/input-event-codes.h :${SYSROOT_PREFIX}/usr/include/linux/input-event-codes.h:g" \{} \;
}

make_target() {
  python setup.py build_ext \
  build_ecodes --evdev-headers ${SYSROOT_PREFIX}/usr/include/linux/input.h:${SYSROOT_PREFIX}/usr/include/linux/input-event-codes.h \
  build_ext --include-dirs ${SYSROOT_PREFIX}/usr/include/
}

makeinstall_target() {
  python setup.py install --root=${INSTALL} --prefix=/usr
}

