#!/bin/bash -ex

# CONFIG
prefix="CrashPlanPro"
suffix=""
package_name="CrashPlanPro"
display_name="CrashPlan Pro Backup Client"

if [ "x$1" == "x" ]; then
	echo "Usage: ./build.sh <Path-To-Package>"
	exit 1
fi

url=$1

# copy package
cp "${url}" app.dmg

# Mount
mountpoint=`hdiutil attach -mountrandom /tmp -nobrowse app.dmg | awk '/private\/tmp/ { print $NF } '`

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
key_files=`find build-root -name '*.app' -or -name '*.plugin' -or -name '*.prefPane' -or -name '*component' | sed 's/ /\\\\ /g; s/^/-f /' | paste -s -d ' ' -`

# plist prefers full paths
plist=`pwd`/app.plist

# Build pkginfo (this is done through an echo to expand key_files)
echo /usr/local/munki/makepkginfo -m go-w -g admin -o root app.dmg ${key_files} | /bin/bash > ${plist}

# Remove "build-root" from file paths
perl -p -i -e 's/build-root/\/Applications/' ${plist}

# Obtain and set version
versionplist="`pwd`/build-root/CrashPlan.app/Contents/Info.plist"
version=`defaults read "${versionplist}" CFBundleShortVersionString`
defaults write "${plist}" version "${version}"

# Change path and other details in the plist
defaults write "${plist}" installer_item_location "${prefix}-${version}${suffix}.dmg"
defaults write "${plist}" minimum_os_version "10.7.0"
defaults write "${plist}" uninstallable -bool NO
defaults write "${plist}" name "${package_name}"
defaults write "${plist}" display_name "${display_name}"
defaults write "${plist}" requires -array "Java6"

# Make readable by humans
/usr/bin/plutil -convert xml1 "${plist}"
chmod a+r "${plist}"

# Change filenames to suit
mv app.dmg   ${prefix}-${version}${suffix}.dmg
mv app.plist ${prefix}-${version}${suffix}.plist

# Cleanup
rm -rf build-root tmp