# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="emuelec-emulationstation"
PKG_VERSION="9ba118ea4f67ad11d45248ba38abdd86e3fb022f"
PKG_GIT_CLONE_BRANCH="EmuELEC"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/EmuELEC/emuelec-emulationstation"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain SDL2 freetype curl freeimage vlc bash rapidjson ${OPENGLES} SDL2_mixer fping p7zip"
PKG_SECTION="emuelec"
PKG_NEED_UNPACK="busybox"
PKG_SHORTDESC="Emulationstation emulator frontend"
PKG_BUILD_FLAGS="-gold"
GET_HANDLER_SUPPORT="git"

# themes for Emulationstation
#PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET Crystal"
PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET es-theme-EmuELEC-carbon es-theme-ComicBook"

pre_configure_target() {

PKG_CMAKE_OPTS_TARGET=" -DENABLE_EMUELEC=1 -DDISABLE_KODI=1 -DENABLE_FILEMANAGER=1 -DGLES2=1 "

# Read api_keys.txt if it exist to add the required keys for cheevos, thegamesdb and screenscrapper. You need to get your own API keys. 
# File should be in this format
# -DSCREENSCRAPER_DEV_LOGIN=devid=<devusername>&devpassword=<devpassword> 
# -DGAMESDB_APIKEY=<gamesdbapikey>
# -DCHEEVOS_DEV_LOGIN=z=<yourusername>&y=<yourapikey>
# and it should be placed next to this file

if [ -f ${PKG_DIR}/api_keys.txt ]; then
while IFS="" read -r p || [ -n "$p" ]
do
  PKG_CMAKE_OPTS_TARGET+=" $p"
done < ${PKG_DIR}/api_keys.txt
fi

if [[ ${DEVICE} == "GameForce" ]]; then
PKG_CMAKE_OPTS_TARGET+=" -DENABLE_GAMEFORCE=1"
fi

if [[ ${DEVICE} == "OdroidGoAdvance"  ]]; then
PKG_CMAKE_OPTS_TARGET+=" -DODROIDGOA=1"
fi

}

#post_configure_target() {
#cd $PKG_BUILD
#echo ${PWD} > 111.txt
#
#}


pre_make_target() {
  sed -i -e 's/-std=gnu++11//' build.ninja
}

makeinstall_target() {
	PKG_PYTHON_VERSION="python3.7"
	mkdir -p ${INSTALL}/usr/config/emuelec/configs/locale/i18n/charmaps
	cp -rf $PKG_BUILD/locale/lang/* ${INSTALL}/usr/config/emuelec/configs/locale/
	cp -PR "$(get_build_dir glibc)/localedata/charmaps/UTF-8" ${INSTALL}/usr/config/emuelec/configs/locale/i18n/charmaps/UTF-8
	
	mkdir -p ${INSTALL}/usr/lib
	ln -sf /storage/.config/emuelec/configs/locale ${INSTALL}/usr/lib/locale
	
	mkdir -p ${INSTALL}/usr/config/emulationstation/resources
    cp -rf $PKG_BUILD/resources/* ${INSTALL}/usr/config/emulationstation/resources/
    # Ultra Retro Pi branding over the stock EmuELEC splash/logo
    cp -f ${PKG_DIR}/branding/logo.png ${INSTALL}/usr/config/emulationstation/resources/logo.png
    for svg in splash_emuelec.svg splash.svg splash_batocera.svg; do
        cp -f ${PKG_DIR}/branding/splash_emuelec.svg ${INSTALL}/usr/config/emulationstation/resources/${svg}
    done

    # translations are read straight from the .po files (zzz_po_locale.patch), not through a glibc locale
    for po in $PKG_BUILD/locale/lang/*/LC_MESSAGES/emulationstation2.po; do
        lang=$(basename $(dirname $(dirname ${po})))
        mkdir -p ${INSTALL}/usr/config/emulationstation/resources/locale/${lang}/LC_MESSAGES
        cp ${po} ${INSTALL}/usr/config/emulationstation/resources/locale/${lang}/LC_MESSAGES/
    done
    
	mkdir -p ${INSTALL}/usr/lib/${PKG_PYTHON_VERSION}
	cp -rf ${PKG_DIR}/bluez/* ${INSTALL}/usr/lib/${PKG_PYTHON_VERSION}
	
    mkdir -p ${INSTALL}/usr/bin
    ln -sf /storage/.config/emulationstation/resources ${INSTALL}/usr/bin/resources
    cp -rf $PKG_BUILD/emulationstation ${INSTALL}/usr/bin
    cp -PR "$(get_build_dir glibc)/.$TARGET_NAME/locale/localedef" ${INSTALL}/usr/bin

	mkdir -p ${INSTALL}/etc/emulationstation/
	ln -sf /storage/.config/emulationstation/themes ${INSTALL}/etc/emulationstation/
   
	mkdir -p ${INSTALL}/usr/config/emulationstation
	cp -rf ${PKG_DIR}/config/scripts ${INSTALL}/usr/config/emulationstation
	cp -rf ${PKG_DIR}/config/*.cfg ${INSTALL}/usr/config/emulationstation

	chmod +x ${INSTALL}/usr/config/emulationstation/scripts/*
	chmod +x ${INSTALL}/usr/config/emulationstation/scripts/configscripts/*
	find ${INSTALL}/usr/config/emulationstation/scripts/ -type f -exec chmod o+x {} \; 
	
	# Vertical Games are only supported in the OdroidGoAdvance
    if [[ ${DEVICE} != "OdroidGoAdvance" ]]; then
        sed -i "s|, vertical||g" "${INSTALL}/usr/config/emulationstation/es_features.cfg"
    fi
	
	# Amlogic project has an issue with mixed audio
    if [[ "${DEVICE}" == "Amlogic" ]]; then
        sed -i "s|</config>|	<bool name=\"StopMusicOnScreenSaver\" value=\"false\" />\n</config>|g" "${INSTALL}/usr/config/emulationstation/es_settings.cfg"
    fi

    if [[ "${DEVICE}" == "OdroidGoAdvance" ]] || [[ "${DEVICE}" == "GameForce" ]]; then
        sed -i "s|<\/config>|	<string name=\"GamelistViewStyle\" value=\"Small Screen\" />\n<\/config>|g" "${INSTALL}/usr/config/emulationstation/es_settings.cfg"
        sed -i "s|value=\"panel\" />|value=\"small panel\" />|g" "${INSTALL}/usr/config/emulationstation/es_settings.cfg"
    fi
    
    if  [[ "${DEVICE}" == "GameForce" ]]; then
    	mkdir -p ${INSTALL}/usr/config/emulationstation/themesettings
        sed -i "s|<\/config>|	<string name=\"subset.ratio\" value=\"43\" />\n<\/config>|g" "${INSTALL}/usr/config/emulationstation/es_settings.cfg"
        echo "subset.ratio=43" > ${INSTALL}/usr/config/emulationstation/themesettings/Crystal.cfg
    fi

# Remove unused cores
CORESFILE="${INSTALL}/usr/config/emulationstation/es_systems.cfg"

if [ "${DEVICE}" != "Amlogic-ng" ]; then
    if [[ ${DEVICE} == "OdroidGoAdvance" || "$DEVICE" == "GameForce" ]]; then
        remove_cores="mesen-s quicknes mame2016 mesen"
    elif [ "${DEVICE}" == "Amlogic" ]; then
        remove_cores="mesen-s quicknes mame2016 mesen"
        xmlstarlet ed -L -P -d "/systemList/system[name='saturn']" ${CORESFILE}
    fi
    
    for discore in ${remove_cores}; do
        sed -i "s|<core>$discore</core>||g" ${CORESFILE}
        sed -i '/^[[:space:]]*$/d' ${CORESFILE}
    done
fi

# Remove Retrorun For unsupported devices
if [[ ${DEVICE} != "OdroidGoAdvance" ]] && [[ "${DEVICE}" != "GameForce" ]]; then
	xmlstarlet ed -L -P -d "/systemList/system/emulators/emulator[@name='retrorun']" ${CORESFILE}
else
	# remove duckstation for the OGA/GF
	xmlstarlet ed -L -P -d "/systemList/system/emulators/emulator[@name='Duckstation']" ${CORESFILE}

	# set parallel_n64_32b as default for handhelds
	sed -i "s|<core default=\"true\">mupen64plus_next</core>|<core>mupen64plus_next</core>|g" ${CORESFILE}
	sed -i "s|<core>parallel_n64_32b</core>|<core default=\"true\">parallel_n64_32b</core>|g" ${CORESFILE}
fi

# H3 can't run these at playable speed, hide them from the menu
if [ "${PROJECT}" == "H3" ]; then
	for dissystem in dreamcast naomi atomiswave psp pspminis n64 ports; do
		xmlstarlet ed -L -P -d "/systemList/system[name='${dissystem}']" ${CORESFILE}
	done

	# SAFE SHUTDOWN in the system carousel, right after Setup (scripts/shutdown is in emuelec,
	# the art in the ComicBook overlay)
	xmlstarlet ed -L -P -a "/systemList/system[name='setup']" -t elem -n systemTMP -v "" \
		-s "//systemTMP" -t elem -n name -v "shutdown" \
		-s "//systemTMP" -t elem -n fullname -v "Safe Shutdown" \
		-s "//systemTMP" -t elem -n manufacturer -v "Ultra Retro Pi" \
		-s "//systemTMP" -t elem -n release -v "2026" \
		-s "//systemTMP" -t elem -n hardware -v "system" \
		-s "//systemTMP" -t elem -n path -v "/usr/bin/scripts/shutdown" \
		-s "//systemTMP" -t elem -n extension -v ".sh" \
		-s "//systemTMP" -t elem -n command -v "/usr/bin/bash %ROM%" \
		-s "//systemTMP" -t elem -n platform -v "ignore" \
		-s "//systemTMP" -t elem -n theme -v "shutdown" \
		-r "//systemTMP" -v "system" ${CORESFILE}

	# lighter default cores for the Cortex-A7 (the others stay selectable)
	# arcade: FBNeo first (lighter than MAME, less lag); Setup > Auto Games Setup moves the games
	# whose ROM set only matches MAME 2003-Plus
	for syscore in gba:gpsp snes:snes9x2010 nes:fceumm megadrive:picodrive genesis:picodrive segacd:picodrive arcade:fbneo; do
		xmlstarlet ed -L -P -d "/systemList/system[name='${syscore%%:*}']//core/@default" \
			-i "/systemList/system[name='${syscore%%:*}']//core[.='${syscore##*:}']" -t attr -n default -v true ${CORESFILE}
	done
fi

}

post_install() {  
	enable_service emustation.service
	enable_service bluetooth-agent.service
	mkdir -p ${INSTALL}/usr/share
	ln -sf /storage/.config/emuelec/configs/locale ${INSTALL}/usr/share/locale
	mkdir -p ${INSTALL}/usr/bin/batocera/
	ln -sf /usr/bin/7zr ${INSTALL}/usr/bin/batocera/7zr
}
