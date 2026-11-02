################################################################################
#      This file is part of OpenELEC - http://www.openelec.tv
#      Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
#
#  This Program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2, or (at your option)
#  any later version.
#
#  This Program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with OpenELEC.tv; see the file COPYING.  If not, write to
#  the Free Software Foundation, 51 Franklin Street, Suite 500, Boston, MA 02110, USA.
#  http://www.gnu.org/copyleft/gpl.html
################################################################################

PKG_NAME="opera"
PKG_VERSION="54fe4f3754e9b69c83ff50b5def5d6c60fef06ce"
PKG_SHA256="1034d58acb38cd9fcb08da6d90980edd6a0439aaa9d47735f1c85d8e6143122b"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="LGPL with additional notes"
PKG_SITE="https://github.com/libretro/opera-libretro"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_SHORTDESC="Port of 4DO/libfreedo to libretro."
PKG_LONGDESC="Port of 4DO/libfreedo to libretro."
PKG_TOOLCHAIN="make"


make_target() {
  make CC=$CC CXX=$CXX AR=$AR
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp opera_libretro.so $INSTALL/usr/lib/libretro/
}
