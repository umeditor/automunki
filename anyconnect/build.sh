#!/bin/bash -ex

# CONFIG
prefix="CiscoAnyConnectVPN"
suffix=""
package_name="Cisco AnyConnect VPN"

if [ "x$1" == "x" ]; then
	echo "Usage: ./build.sh <Path-To-Package>"
	exit 1
fi

url=$1

# copy package
cp "${url}" app.dmg

# Build pkginfo
/usr/local/munki/makepkginfo -m go-w -g admin -o root app.dmg > app.plist

plist=`pwd`/app.plist

# Obtain version info
version=`defaults read "${plist}" version`

# Change path and other details in the plist
defaults write "${plist}" installer_item_location "${prefix}-${version}${suffix}.dmg"
defaults write "${plist}" minimum_os_version "10.7.0"
defaults write "${plist}" uninstallable -bool NO
defaults write "${plist}" name "${package_name}"

# Make readable by humans
/usr/bin/plutil -convert xml1 "${plist}"
chmod a+r "${plist}"

# Change filenames to suit
mv app.dmg   ${prefix}-${version}${suffix}.dmg
mv app.plist ${prefix}-${version}${suffix}.plist