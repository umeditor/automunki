#!/bin/bash -ex

# CONFIG
prefix="Office2011"
suffix="-update"
package_name="Office2011Update"

if [ "x$1" == "x" ]; then
	echo "Usage: ./build.sh <URL-To-Package>"
	exit 1
fi

url=$1

# download the big package
curl -o update.dmg "${url}"

# Mount
mountpoint=`hdiutil attach -mountrandom /tmp -nobrowse update.dmg | awk '/private\/tmp/ { print $NF } '`

# Extract update
pkgutil --expand "${mountpoint}"/*.pkg tmp

# unmount
hdiutil detach "${mountpoint}"

# Extract packages
mkdir -p build-root
for payload in tmp/*.pkg/Payload; do
	echo $payload
	(cd build-root; pax -rz -f "../${payload}")
done

# Find all the appropriate apps, etc, and then turn that into -f's
key_files=`find build-root/Applications -name '*.app' -or -name '*.plugin' -or -name '*.prefPane' -or -name '*component' -maxdepth 2 | grep -v "Document Connection" | sed 's/ /\\\\ /g; s/^/-f /' | paste -s -d ' ' -`

# Build pkginfo (this is done through an echo to expand key_files)
echo /usr/local/munki/makepkginfo -m go-w -g admin -o root update.dmg ${key_files} | /bin/bash > app.plist

# Remove "build-root" from file paths
perl -p -i -e 's/build-root//' app.plist

# plist prefers full paths
plist=`pwd`/app.plist

# Obtain version info
version=`defaults read "${plist}" version`

# Change path and other details in the plist
defaults write "${plist}" installer_item_location "jenkins/${prefix}-${version}${suffix}.dmg"
defaults write "${plist}" minimum_os_version "10.6.0"
defaults write "${plist}" uninstallable -bool NO
defaults write "${plist}" name "${package_name}"
defaults write "${plist}" display_name "Microsoft Office Update"
defaults write "${plist}" update_for -array "Office2011"
defaults write "${plist}" requires -array "Office2011-14.2.0"

# Make readable by humans
/usr/bin/plutil -convert xml1 "${plist}"
chmod a+r "${plist}"

# Change filenames to suit
cp update.dmg ${prefix}-${version}${suffix}.dmg
mv app.plist 	 ${prefix}-${version}${suffix}.plist

