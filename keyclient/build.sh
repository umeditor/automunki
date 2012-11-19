#!/bin/bash -ex

# CONFIG
prefix="K2Client"
suffix="-lsa"
package_name="K2Client"
url="http://www.sassafras.com/links/K2Client-Config.dmg"

. settings.sh

# download the big package
ftp -o app-ro.dmg "${url}"

# Mount it and extract out the client dmg (from older k2 complete archive)
# mountpoint=`hdiutil attach -mountrandom /tmp -nobrowse k2-complete.dmg | awk '/private\/tmp/ { print $NF } '`
# cp "${mountpoint}/Installers/Macintosh Installers/Misc/K2Client-Config.dmg" app-ro.dmg
# hdiutil detach "${mountpoint}"

# Convert to RW - want to run their config utility
hdiutil convert -format UDRW app-ro.dmg -o app-rw.dmg
mountpoint=`hdiutil attach -mountrandom /tmp -nobrowse app-rw.dmg | awk '/private\/tmp/ { print $NF } '`

# -h      hostname of keyserver
# -s 2    user cannot change any settings when deploying
# -g yes  override KA address
# -c yes  install keyCheckout
# -t yes  install KeyVerify
# -p yes  install KeyAccess Pref Pane
# -a no   no KeyAccess Classic
# -k yes  kill KeyAccess before install
# -r yes  run KeyAccess after install
# -b no   reboot after install
# -o no   don't delete receipts
# -l yes  lock KeyAccess settings
# -f 0    use Sharing pane for hostname
# -z user use user name as login name
"${mountpoint}/K2Client.mpkg/Contents/Resources/k2clientconfig" -h ${SERVER} -s 2 -g yes -c yes -t yes -p yes -a no -k yes -r yes -b no -o no -l yes -f 0 -z user

# Didn't work - die now
if [ $? != 0 ]; then
	hdiutil detach "${mountpoint}"
	exit $?
fi
hdiutil detach "${mountpoint}"

# Convert back to RW
hdiutil convert -format UDZO app-rw.dmg -o app.dmg

# Mount it to extract some files
mountpoint=`hdiutil attach -mountrandom /tmp -nobrowse app-ro.dmg | awk '/private\/tmp/ { print $NF } '`
mkdir -p build-root/Library
for pkg in "${mountpoint}/K2Client.mpkg/Contents/"*.pkg/Contents/Archive.pax.gz; do
	echo $pkg
	(cd build-root/Library; pax -rz -f "$pkg")
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
defaults write "${plist}" minimum_os_version "10.6.0"
defaults write "${plist}" uninstallable -bool NO
defaults write "${plist}" name "${package_name}"
defaults write "${plist}" display_name "Sassafras KeyClient"

# Make readable by humans
/usr/bin/plutil -convert xml1 "${plist}"
chmod a+r "${plist}"

# Change filenames to suit
cp app.dmg   ${prefix}-${version}${suffix}.dmg
mv app.plist ${prefix}-${version}${suffix}.plist

