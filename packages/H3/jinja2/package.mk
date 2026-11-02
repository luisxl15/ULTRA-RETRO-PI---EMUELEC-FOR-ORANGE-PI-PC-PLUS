# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="jinja2"
PKG_VERSION="d9756e1acc19c1788d21a2d1076f8e6a0f55d6da"
PKG_SHA256=""
PKG_LICENSE="OSS"
PKG_SITE="https://github.com/pallets/jinja"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain Python3 distutilscross:host"
# install the pinned MarkupSafe first, or setup.py pulls the latest from PyPI (needs a newer Python)
PKG_DEPENDS_HOST="Python3:host setuptools:host MarkupSafe:host"
PKG_LONGDESC="Python 2 and 3 compatibility library "
PKG_TOOLCHAIN="manual"

make_host() {
  python3 setup.py build
}

makeinstall_host() {
  python3 setup.py install --prefix=$TOOLCHAIN
}
