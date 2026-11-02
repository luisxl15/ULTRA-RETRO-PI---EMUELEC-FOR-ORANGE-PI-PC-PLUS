# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)

PKG_NAME="soundfont-generaluser"
PKG_VERSION="1.471"
PKG_SHA256="0229b2a75a717aa7337fd1802432e2cf36a5307e506fcb5d6ff7023192e037c4"
PKG_LICENSE="OSS"
PKG_SITE="http://www.schristiancollins.com/generaluser.php"
# the original Dropbox link is dead; ROCKNIX keeps the same v1.471 release in git
PKG_URL="https://github.com/ROCKNIX/generaluser-gs/archive/8fe2798d527f1dfa2d58baf78ac7b1820a575703.tar.gz"
PKG_SOURCE_DIR="generaluser-gs-*"
PKG_DEPENDS_TARGET=""
PKG_LONGDESC="GeneralUser GS is a GM and GS compatible SoundFont bank for composing, playing MIDI files, and retro gaming."
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p $INSTALL/usr/share/soundfonts
  cp GeneralUser*$PKG_VERSION.sf2 $INSTALL/usr/share/soundfonts/GeneralUser.sf2
}
