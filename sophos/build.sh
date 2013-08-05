#!/bin/bash -ex

# CONFIG
prefix="SophosAntiVirus"
suffix=""
package_name="SophosAntiVirus"
display_name="Sophos Anti-Virus"
description="This software detects and cleans up viruses, Trojans, worms and spyware, as well as adware and other potentially unwanted applications."

if [ "x$1" == "x" ]; then
	echo "Usage: ./build.sh <Path-To-Package>"
	exit 1
fi

url=$1

# copy package
cp "${url}" app.dmg

# Mount
mountpoint=`hdiutil attach -mountrandom /tmp -nobrowse app.dmg | awk '/private\/tmp/ { print $NF } '`

# Extract all sub-packages
mkdir -p build-root
find "${mountpoint}/Sophos Anti-Virus.mpkg" -name *.pkg -type d -exec sh -c '
	pkg="$0"
	echo "$pkg"
	(cd build-root; pax -rz -f "$pkg/Contents/Archive.pax.gz")
' {} ';'

# unmount
hdiutil detach "${mountpoint}"

# Find all the appropriate apps, etc, and then turn that into -f's
key_files=`find build-root -name '*.app' -or -name '*.plugin' -or -name '*.prefPane' -or -name '*component' -maxdepth 3 | grep -v "Document Connection" | sed 's/ /\\\\ /g; s/^/-f /' | paste -s -d ' ' -`

# Build pkginfo (this is done through an echo to expand key_files)
echo /usr/local/munki/makepkginfo -m go-w -g admin -o root app.dmg ${key_files} | /bin/bash > app.plist

# Remove "build-root" from file paths
perl -p -i -e 's/build-root//' app.plist

# plist prefers full paths
plist=`pwd`/app.plist

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