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

# Copy deploy package
mkdir build-root
ditto "${mountpoint}/VMware Fusion.app/Contents/Library/Deploy VMware Fusion.mpkg" "build-root/Deploy VMware Fusion.mpkg"

# Add the serial number
echo "key = ${serial}" >> "build-root/Deploy VMware Fusion.mpkg/Contents/00Fusion_Deployment_Items/Deploy.ini"

# Copy app for modification
ditto "${mountpoint}/VMware Fusion.app" "build-root/Deploy VMware Fusion.mpkg/Contents/00Fusion_Deployment_Items/VMware Fusion.app"

# unmount
hdiutil detach "${mountpoint}"

# remove original dmg
rm app.dmg

# Create disk image from modified app
hdiutil create -volname "VMware Fusion" -srcfolder "build-root/Deploy VMware Fusion.mpkg" -ov -format UDZO app.dmg

# Find all the appropriate apps, etc, and then turn that into -f's
key_files=`find build-root -name '*.app' -or -name '*.plugin' -or -name '*.prefPane' -or -name '*component' | sed 's/ /\\\\ /g; s/^/-f /' | paste -s -d ' ' -`

# plist prefers full paths
plist=`pwd`/app.plist
versionplist="`pwd`/build-root/Deploy VMware Fusion.mpkg/Contents/00Fusion_Deployment_Items/VMware Fusion.app/Contents/Info.plist"

# Build pkginfo (this is done through an echo to expand key_files)
echo /usr/local/munki/makepkginfo -m go-w -g admin -o root app.dmg ${key_files} | /bin/bash > ${plist}

# Fix paths
perl -p -i -e 's/build-root\/Deploy VMware Fusion.mpkg\/Contents\/00Fusion_Deployment_Items/Applications/' ${plist}

# Obtain and set version
version=`defaults read "${versionplist}" CFBundleShortVersionString`
defaults write "${plist}" version "${version}"

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