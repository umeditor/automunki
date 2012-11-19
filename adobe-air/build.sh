#!/bin/bash -ex

# download latest Adobe AIR
ftp -o adobeair.dmg http://airdownload.adobe.com/air/mac/download/latest/AdobeAIR.dmg

# Mount disk image on temp space
mountpoint=`hdiutil attach -mountrandom /tmp -nobrowse adobeair.dmg | awk '/private\/tmp/ { print $3 } '`
echo Mounted on $mountpoint

# Obtain version
version=`defaults read "$mountpoint/Adobe AIR Installer.app/Contents/Frameworks/Adobe AIR.framework/Resources/Info.plist" CFBundleVersion`

# Make a disk image with just the framework on it
hdiutil create -srcfolder "$mountpoint/Adobe AIR Installer.app/Contents/Frameworks" -format UDZO -o AdobeAIR-${version}.dmg
hdiutil detach "$mountpoint"

# Build pkginfo
plist=`pwd`/AdobeAIR-${version}.plist

/usr/local/munki/makepkginfo AdobeAIR-${version}.dmg -i 'Adobe AIR.framework' -d /Library/Frameworks --postinstall_script "postinstall.sh" > "$plist"

# Change path and other details in the plist
defaults write "${plist}" installer_item_location "jenkins/AdobeAIR-${version}.dmg"
defaults write "${plist}" minimum_os_version "10.7.0"
defaults write "${plist}" uninstallable -bool NO
defaults write "${plist}" display_name "Adobe AIR Framework"
defaults write "${plist}" name "AdobeAIR"
defaults write "${plist}" requires '( "AdobeFlashPlayer" )'

# Make readable by humans
/usr/bin/plutil -convert xml1 "$plist"
chmod a+r "$plist"
