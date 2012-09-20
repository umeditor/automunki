#!/bin/bash -ex

# CONFIG
prefix="OpenOffice"
suffix=""
package_name="OpenOffice"
url=`cat /var/tmp/OpenOfficeURL`

# download it
curl -L -o app.dmg $url

# Build pkginfo
/usr/local/munki/makepkginfo -m go-w -g admin -o root app.dmg > app.plist

plist=`pwd`/app.plist

# Obtain version info
version=`defaults read "${plist}" version`

# Change path and other details in the plist
defaults write "${plist}" installer_item_location "jenkins/${prefix}-${version}${suffix}.dmg"
defaults write "${plist}" minimum_os_version "10.7.0"
defaults write "${plist}" uninstallable -bool NO
defaults write "${plist}" name "${package_name}"
defaults write "${plist}" requires -array JavaForMacOSX

# Make readable by humans
/usr/bin/plutil -convert xml1 "${plist}"
chmod a+r "${plist}"

# Change filenames to suit
mv app.dmg   ${prefix}-${version}${suffix}.dmg
mv app.plist ${prefix}-${version}${suffix}.plist

