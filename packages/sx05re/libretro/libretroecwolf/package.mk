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

PKG_NAME="libretroecwolf"
PKG_VERSION="18eca17c2d634b154824e0782c6cbbe0a2c9ea76"
PKG_ARCH="any"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/libretro/ecwolf"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_SHORTDESC="An unofficial libretro port of the EasyRPG/Player."
PKG_LONGDESC="An unofficial libretro port of the EasyRPG/Player."
PKG_TOOLCHAIN="cmake"
PKG_BUILD_FLAGS="+pic"

PKG_IS_ADDON="no"
PKG_AUTORECONF="no"

PKG_CMAKE_OPTS_TARGET=" -DNO_GTK=ON \
						-DFORCE_CROSSCOMPILE=ON \
						-DIMPORT_EXECUTABLES=$PKG_BUILD/.$HOST_NAME/ImportExecutables.cmake						
						-DCMAKE_BUILD_TYPE=Release -DSDL2_LIBRARY=$SYSROOT_PREFIX/usr/lib"



makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp $PKG_BUILD/.$TARGET_NAME/ecwolf_libretro.so $INSTALL/usr/lib/libretro/
}
