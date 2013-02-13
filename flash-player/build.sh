#!/bin/bash -ex

pwd="`pwd`"

# download latest
ftp -o flash.dmg http://fpdownload.macromedia.com/get/flashplayer/current/licensing/mac/install_flash_player_11_osx.dmg

# Mount disk image on temp space
mountpoint=`hdiutil attach -mountrandom /tmp -nobrowse flash.dmg | awk '/private\/tmp/ { print $3 } '`
echo Mounted on $mountpoint

# Obtain version
cp "$mountpoint/Install Adobe Flash Player.app/Contents/Resources/Adobe Flash Player.pkg/Contents/Info.plist" version-info.plist
version=`defaults read "${pwd}/version-info" CFBundleShortVersionString`

# Make a disk image with just the framework on it
#hdiutil create -srcfolder "$mountpoint/Adobe AIR Installer.app/Contents/Frameworks" -format UDZO -o AdobeAIR-${version}.dmg
hdiutil detach "$mountpoint"
mv flash.dmg AdobeFlashPlayer-${version}.dmg

# Build pkginfo
plist="`pwd`/AdobeFlashPlayer-${version}.plist"

/usr/local/munki/makepkginfo AdobeFlashPlayer-${version}.dmg -p 'Install Adobe Flash Player.app/Contents/Resources/Adobe Flash Player.pkg' > "$plist"

# Change path and other details in the plist
defaults write "${plist}" installer_item_location "jenkins/AdobeFlashPlayer-${version}.dmg"
defaults write "${plist}" minimum_os_version "10.7.0"
defaults write "${plist}" uninstallable -bool NO
defaults write "${plist}" display_name "Adobe Flash Plug-In"
defaults write "${plist}" name "AdobeFlashPlayer"
defaults write "${plist}" installs "( { CFBundleShortVersionString = \"$version\"; path = \"/Library/Internet Plug-Ins/Flash Player.plugin\"; type = \"bundle\"; } )"

# Make readable by humans
/usr/bin/plutil -convert xml1 "$plist"
chmod a+r "$plist"
