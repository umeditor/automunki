#!/bin/bash -ex

# CONFIG
prefix="PackageName"
suffix=""
munki_package_name="PackageName"
display_name="Package Name"
url=`./finder.sh`

# download it (-L: follow redirects)
curl -L -o app.dmg -A 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/536.26.17 (KHTML, like Gecko) Version/6.0.2 Safari/536.26.17' "${url}"

# Build pkginfo
/usr/local/munki/makepkginfo app.dmg > app.plist

plist=`pwd`/app.plist

# Obtain version info
version=`defaults read "${plist}" version`

# Change path and other details in the plist
defaults write "${plist}" installer_item_location "jenkins/${prefix}-${version}${suffix}.dmg"
defaults write "${plist}" minimum_os_version "10.7.0"
defaults write "${plist}" uninstallable -bool NO
defaults write "${plist}" name "${munki_package_name}"
defaults write "${plist}" display_name "${display_name}"

# Make readable by humans
/usr/bin/plutil -convert xml1 "${plist}"
chmod a+r "${plist}"

# Change filenames to suit
mv app.dmg   ${prefix}-${version}${suffix}.dmg
mv app.plist ${prefix}-${version}${suffix}.plist
