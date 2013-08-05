#!/bin/bash -ex

# CONFIG
prefix="VMwareFusion"
suffix=""
package_name="VMwareFusion"
display_name="VMware Fusion"
description="VMware Fusion is a desktop application that lets you create and run virtual machines on your Intel-based Macintosh."

source serial.sh

if [ "x$1" == "x" ] || [ "x$2" == "x" ] ; then
	echo "Usage: ./build.sh <Path-To-Package> <Serial-Number>"
	exit 1
fi

url=$1
serial=$2

# copy package
cp "${url}" app.dmg

# Mount
mountpoint=`hdiutil attach -mountrandom /tmp -nobrowse app.dmg | awk '/private\/tmp/ { print $NF } '`

# Copy app for modification
mkdir build-root
ditto "${mountpoint}/VMware Fusion.app" "build-root/VMware Fusion.app"

# unmount
hdiutil detach "${mountpoint}"

# remove original dmg
rm app.dmg

# Add the serial number
echo "key = ${serial}" >> "build-root/VMware Fusion.app/Contents/Library/Deploy VMware Fusion.mpkg/Contents/00Fusion_Deployment_Items/Deploy.ini"

# Create disk image from modified app
hdiutil create -volname "VMware Fusion" -srcfolder "build-root/VMware Fusion.app" -ov -format UDZO app.dmg

# Build pkginfo
plist=`pwd`/app.plist
/usr/local/munki/makepkginfo -m go-w -g admin -o root app.dmg > "${plist}"

# Obtain version info
version=`defaults read "${plist}" version`

# Change path and other details in the plist
defaults write "${plist}" installer_item_location "${prefix}-${version}${suffix}.dmg"
defaults write "${plist}" minimum_os_version "10.7.0"
defaults write "${plist}" uninstallable -bool NO
defaults write "${plist}" name "${package_name}"
defaults write "${plist}" display_name "${display_name}"
defaults write "${plist}" description "${description}"

# Make readable by humans
/usr/bin/plutil -convert xml1 "${plist}"
chmod a+r "${plist}"

# Change filenames to suit
mv app.dmg   ${prefix}-${version}${suffix}.dmg
mv app.plist ${prefix}-${version}${suffix}.plist

# Cleanup
chmod -R u+w build-root
rm -rf build-root tmp
exit