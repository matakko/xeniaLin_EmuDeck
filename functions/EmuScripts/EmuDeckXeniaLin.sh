#!/bin/bash
#variables
Xenia_emuName="Xenia"
Xenia_emuType="$emuDeckEmuTypeBinary"
Xenia_emuPath="$emusFolder"
Xenia_releaseURL_canary="https://github.com/xenia-canary/xenia-canary-releases/releases/latest/download/xenia_canary_linux.tar.gz"
Xenia_dir="$HOME/.local/share/Xenia"
Xenia_XeniaSettings="$HOME/.local/share/Xenia/xenia-canary.config.toml"
# check TODO for find stuff todo or to finish

#cleanupOlderThings TODO
Xenia_cleanup(){
	echo "NYI"
}

#Install
Xenia_install(){
    echo "Begin xenia_canary Install"
    local showProgress="$1"

    local archiveName="xenia_canary_linux"

    if installEmuBI "$Xenia_emuName" "$Xenia_releaseURL_canary" "$archiveName" "tar.gz" "$showProgress"; then
        mkdir -p "$Xenia_dir/content"
        tar -xvf "$emusFolder/${archiveName}.tar.gz" -C "$Xenia_emuPath"
        rm -f "$emusFolder/${archiveName}.tar.gz"
        mv "$Xenia_emuPath/LICENSE" "$Xenia_dir/LICENSE"
        chmod +x "$Xenia_emuPath/xenia_canary"
    else
        return 1
    fi
}

#ApplyInitialSettings
Xenia_init(){
	echo "Initializing Xenia Config"

    mkdir -p "$romsPath/xbox360/roms/xbla" #doest it need to be symlink to local/share/xenia  ? TODO
    configEmuAI "Xenia" "config" "$Xenia_dir" "$emudeckBackend/configs/xenia" "true"

#    Xenia_setupStorage TODO (pehaps modfiy path patches ? )
    Xenia_setupSaves
    Xenia_getPatches
#    Xenia_finalize TODO check if we need to add some clean
  Xenia_flushEmulatorLauncher
	if [ -e "$ESDE_toolPath" ] || [ -f "${toolsPath}/$ESDE_downloadedToolName" ] || [ -f "${toolsPath}/$ESDE_oldtoolName.AppImage" ]; then
		Xenia_addESConfig
	else
		echo "ES-DE not found. Skipped adding custom system."
	fi
}

#update
Xenia_update(){
	echo "NYI"
	Xenia_setupSaves
#	Xenia_getPatches  TODO verify if its ok to do 
	Xenia_flushEmulatorLauncher
}

#ConfigurePaths
Xenia_setEmulationFolder(){
	echo "NYI"
}

#ConfigureESDE
Xenia_addESConfig(){

	ESDE_junksettingsFile
	ESDE_addCustomSystemsFile
	ESDE_setEmulationFolder

	if [[ $(grep -rnw "$es_systemsFile" -e 'xbox360') == "" ]]; then
		xmlstarlet ed -S --inplace --subnode '/systemList' --type elem --name 'system' \
		--var newSystem '$prev' \
		--subnode '$newSystem' --type elem --name 'name' -v 'xbox360' \
		--subnode '$newSystem' --type elem --name 'fullname' -v 'Microsoft Xbox 360' \
		--subnode '$newSystem' --type elem --name 'path' -v '%ROMPATH%/xbox360/roms' \
		--subnode '$newSystem' --type elem --name 'extension' -v '.iso .ISO . .xex .XEX' \
		--subnode '$newSystem' --type elem --name 'commandP' -v "%STARTDIR%=%EMUDIR% %EMULATOR_XENIALIN% %INJECT%=%BASENAME%.commands %ROM%" \
		--insert '$newSystem/commandP' --type attr --name 'label' --value "Xenia Canary (Linux)" \
		--subnode '$newSystem' --type elem --name 'platform' -v 'xbox360' \
		--subnode '$newSystem' --type elem --name 'theme' -v 'xbox360' \
		-r 'systemList/system/commandP' -v 'command' \
		"$es_systemsFile"

		#format doc to make it look nice
		xmlstarlet fo "$es_systemsFile" > "$es_systemsFile".tmp && mv "$es_systemsFile".tmp "$es_systemsFile"
	fi
	#Custom Systems config end
}
#SetupPatches
Xenia_getPatches() {
	local patches_url="https://github.com/xenia-canary/game-patches/releases/latest/download/game-patches.zip"

	mkdir -p "$Xenia_dir/patches"
	if  [[ ! "$( ls -A "$Xenia_dir/patches")" ]] ; then
		{ curl -L "$patches_url" -o "$Xenia_dir/game-patches.zip" && nice -n 5 unzip -q -o "$Xenia_dir/game-patches.zip" -d "$Xenia_dir" && rm "$Xenia_dir/game-patches.zip"; } &> /dev/null
		echo "Xenia patches downloaded."
	else
		{ curl -L "$patches_url" -o "$Xenia_dir/game-patches.zip" && nice -n 5 unzip -uqo "$Xenia_dir/game-patches.zip" -d "$Xenia_dir" && rm "$Xenia_dir/game-patches.zip"; } &> /dev/null
		echo "Xenia patches updated."
	fi
#	linkTo.... xenia STORAGE? "$Xenia_dir/patches" TODO
}

#SetupSaves
Xenia_setupSaves(){
	mkdir -p "$Xenia_dir/content"
#	linkToSaveFolder xenia saves "$Xenia_dir/content" Or to Rom folders ? TODO
}


#SetupStorage
Xenia_setupStorage(){
	echo "NYI"
}


#WipeSettings
Xenia_wipeSettings(){
	echo "NYI"
}


#Uninstall
Xenia_uninstall(){
	echo "NYI"
# TODO idk what to remove for now a part local/share/xenia and Applications/xenia_canary . launcher maybe ?
#	setMSG "Uninstalling $Xenia_emuName. Saves and ROMs will be retained in the ROMs folder."
#	find ${romsPath}/xbox360 -mindepth 1 \( -name roms -o -name content \) -prune -o -exec rm -rf '{}' \; &>> /dev/null
#	rm -rf $HOME/.local/share/applications/xenia.desktop &> /dev/null
#	rm -rf "${toolsPath}/launchers/xenia.sh"
#	rm -rf "$romsPath/emulators/xenia.sh"
#	rm -rf "$romsPath/xbox360/xenia.sh"
}

#setABXYstyle
Xenia_setABXYstyle(){
	echo "NYI"
}

#Migrate
Xenia_migrate(){
	echo "NYI"
}

#WideScreenOn
Xenia_wideScreenOn(){
	echo "NYI"
}

#WideScreenOff
Xenia_wideScreenOff(){
	echo "NYI"
}

#BezelOn
Xenia_bezelOn(){
	echo "NYI"
}

#BezelOff
Xenia_bezelOff(){
	echo "NYI"
}

#finalExec - Extra stuff
Xenia_finalize(){
	Xenia_cleanup
}

Xenia_IsInstalled(){
	if [ -e "$Xenia_emuPath" ]; then
		echo "true"
	else
		echo "false"
	fi
}

Xenia_resetConfig(){
	mv  "$Xenia_XeniaSettings" "$Xenia_XeniaSettings.bak" &>/dev/null
	Xenia_init &>/dev/null && echo "true" || echo "false"
}

Xenia_setResolution(){
	$xeniaResolution
	echo "NYI"
}

Xenia_cleanESDE(){

	# These files/folders make it so if you have no ROMs in xbox360, it still shows up as an "active" system.
	echo "NYI"
#	if [ -d "${romsPath}/xbox360/.git" ]; then
#		rm -rf "${romsPath}/xbox360/.git"
#	fi

#	if [ -f "$romsPath/xbox360/LICENSE" ]; then
#		mv -f "$romsPath/xbox360/LICENSE" "$romsPath/xbox360/LICENSE.TXT"
#	fi

}

Xenia_flushEmulatorLauncher(){
	flushEmulatorLaunchers "xenia"
}
