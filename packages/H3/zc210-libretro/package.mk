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

PKG_NAME="zc210-libretro"
PKG_VERSION="b6426da40b074245fda097fd345fa7c9cdbf152a"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/netux79/zc210-libretro"
PKG_URL="https://github.com/netux79/zc210-libretro.git"
PKG_DEPENDS_TARGET="toolchain "
PKG_PRIORITY="optional"
PKG_SHORTDESC="A Zelda Classic v2.10 port for libretro (quest player only)."
PKG_LONGDESC="A Zelda Classic v2.10 port for libretro (quest player only)."

PKG_IS_ADDON="no"
PKG_TOOLCHAIN="make"
PKG_AUTORECONF="no"
GET_HANDLER_SUPPORT="git"

make_target() {
    cd $PKG_BUILD
    make 
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  mkdir -p ${INSTALL}/usr/config/zc210

  cp -f ./info/zc210_libretro.info $INSTALL/usr/lib/libretro
  cp -rf ./datfile/* ${INSTALL}/usr/config/zc210
  cp zc210_libretro.so $INSTALL/usr/lib/libretro/
  #ln -s /storage/roms/bios/zc210  ${INSTALL}/usr/config/zc210/
}












