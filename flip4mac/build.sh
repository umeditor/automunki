#!/bin/bash -ex

# CONFIG
prefix="Flip4Mac"
suffix=""
package_name="Flip4Mac"
url=`ruby find-flip4mac.rb`

# download it
ftp -o app.dmg "${url}"

# Mount it to extract some files
mountpoint=`hdiutil attach -mountrandom /tmp -nobrowse app.dmg | awk '/private\/tmp/ { print $NF } '`
mkdir -p build-root

pkgutil --expand "${mountpoint}"/Flip*pkg flat-pack
pwd=`pwd`

for payload in `find "${pwd}/flat-pack" -name 'Payload'`; do
	echo $payload
	(cd build-root; pax -rz -f "$payload")
done

hdiutil detach "$mountpoint"

# Find all the appropriate apps, etc, and then turn that into -f's
key_files=`find build-root -name '*.app' -or -name '*.plugin' -or -name '*.prefPane' -or -name '*component' -maxdepth 3 | sed 's/ /\\\\ /g; s/^/-f /' | paste -s -d ' ' -`

# Build pkginfo (this is done through an echo to expand key_files)
echo /usr/local/munki/makepkginfo -m go-w -g admin -o root app.dmg ${key_files} | /bin/bash > app.plist

# Remove "build-root" from file paths
perl -p -i -e 's/build-root//' app.plist

# plist prefers full paths
plist=`pwd`/app.plist

# Obtain version info
version=`defaults read "${plist}" version`

# Change path and other details in the plist
defaults write "${plist}" installer_item_location "jenkins/${prefix}-${version}${suffix}.dmg"
defaults write "${plist}" minimum_os_version "10.7.0"
defaults write "${plist}" uninstallable -bool NO
defaults write "${plist}" name "${package_name}"

# Make readable by humans
/usr/bin/plutil -convert xml1 "${plist}"
chmod a+r "${plist}"

# Change filenames to suit
mv app.dmg   ${prefix}-${version}${suffix}.dmg
mv app.plist ${prefix}-${version}${suffix}.plist

