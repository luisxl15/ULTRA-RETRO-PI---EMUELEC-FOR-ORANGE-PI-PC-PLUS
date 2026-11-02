PKG_NAME="gearboy"
PKG_VERSION="17e680cc0f63fcbfbf69d62e773fd4efca6204a2"
PKG_SHA256="598363f6ba79b6750f8acd4bb0c7865528bc8fddc5bc3c6e97de335cf4ecf380"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/drhelius/Gearboy"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_SHORTDESC="Game Boy / Gameboy Color emulator for iOS, Mac, Raspberry Pi, Windows and Linux"
PKG_LONGDESC="Game Boy / Gameboy Color emulator for iOS, Mac, Raspberry Pi, Windows and Linux"

PKG_IS_ADDON="no"
PKG_TOOLCHAIN="make"
PKG_AUTORECONF="no"

make_target() {
  make -C platforms/libretro/
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp platforms/libretro/gearboy_libretro.so $INSTALL/usr/lib/libretro/
}
