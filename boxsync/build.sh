#!/bin/bash -ex

# CONFIG
prefix="BoxSync"
suffix=""
package_name="BoxSync"
url="https://sync.box.com/static/sync/release/BoxSyncMac.zip"

# download it
curl -o boxsync.zip $url

# unzip
unzip boxsync.zip

# make DMG from the inner prefpane
mkdir BoxSync
mv *.app/Contents/Resources/*.prefPane BoxSync
hdiutil create -srcfolder BoxSync -format UDZO -o BoxSync.dmg

# Build pkginfo
/usr/local/munki/makepkginfo -m go-w -g admin -o root -i "Box Sync.prefPane" -d "/Library/PreferencePanes" --postinstall_script=postinstall.sh BoxSync.dmg > BoxSync.plist

plist=`pwd`/BoxSync.plist

# Obtain version info
version=`defaults read "${plist}" version`

# Change path and other details in the plist
defaults write "${plist}" installer_item_location "jenkins/${prefix}-${version}${suffix}.dmg"
defaults write "${plist}" minimum_os_version "10.6.8"
defaults write "${plist}" uninstallable -bool NO
defaults write "${plist}" name "${package_name}"

# Make readable by humans
/usr/bin/plutil -convert xml1 "${plist}"
chmod a+r "${plist}"

# Change filenames to suit
mv BoxSync.dmg   ${prefix}-${version}${suffix}.dmg
mv BoxSync.plist ${prefix}-${version}${suffix}.plist

