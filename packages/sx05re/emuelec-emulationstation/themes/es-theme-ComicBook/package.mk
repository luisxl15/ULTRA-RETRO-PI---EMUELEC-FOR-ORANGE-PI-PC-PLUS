# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present Ultra Retro Pi

PKG_NAME="es-theme-ComicBook"
PKG_VERSION="9a68f104b609f5bd7c7a782090817ebe48e9a197"
PKG_SHA256="fad822542cf54d9e7136921ae1759a53545ada79a6e98bcc8ab14223e0b5d582"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="custom"
PKG_SITE="https://github.com/TMNTturtleguy/es-theme-ComicBook"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="emuelec"
PKG_SHORTDESC="ComicBook 16:9 EmulationStation theme by TMNTturtleguy"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  THEME_DIR=$INSTALL/usr/config/emulationstation/themes/es-theme-ComicBook
  mkdir -p $THEME_DIR
    cp -r * $THEME_DIR

  # EmuELEC systems/collections the RetroPie theme never had, and Ultra Retro Pi
  # panels in place of the RetroPie logo
  cp -rf $PKG_DIR/emuelec/* $THEME_DIR

  # every system gets the logo and character in the grid view too
  find $THEME_DIR -name theme.xml -exec sed -i 's|<view name="basic, detailed, video">|<view name="basic, detailed, video, grid">|' {} +
}
