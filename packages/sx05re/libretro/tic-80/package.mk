# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="tic-80"
PKG_VERSION="10957f8493681a8cbb74321f3d346b27939da994"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/nesbox/TIC-80"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="TIC-80 is a fantasy computer for making, playing and sharing tiny games."
GET_HANDLER_SUPPORT="git"

PKG_CMAKE_OPTS_TARGET="-DBUILD_LIBRETRO=ON \
					   -DBUILD_PLAYER=ON \
					   -DBUILD_DEMO_CARTS=OFF \
                       -DBUILD_SOKOL=OFF \
                       -DBUILD_SDL=OFF \
                       -DBUILD_WITH_MRUBY=OFF \
                       -DCMAKE_BUILD_TYPE=Release"

pre_configure_target() {
  # upstream builds its own sources with -Werror, tuned for newer compilers; GCC 9 also
  # warns on the partial struct initializers in src/studio (missing-field-initializers)
  sed -i 's/-Wall -Wextra -Werror)/-Wall -Wextra)/' $PKG_BUILD/cmake/warnings.cmake
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  # newer TIC-80 puts the core in bin/, older ones in lib/
  cp $(ls $PKG_BUILD/.$TARGET_NAME/{bin,lib}/tic80_libretro.so 2>/dev/null | head -1) $INSTALL/usr/lib/libretro/tic80_libretro.so
}
