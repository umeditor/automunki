#!/bin/bash -ex
prefix="CertAid"
suffix=""
package_name="CertAid"
url="https://downloads.mit.edu/released/certaid-for-mac/certaid-for-mac-2_2_1/CertAID-for-mac-2_2_1.zip"

# download it
curl -o app.zip $url
unzip app.zip
hdiutil create -srcfolder CertAid.app CertAid.dmg

# Build pkginfo
/usr/local/munki/makepkginfo -m go-w -g admin -o root CertAid.dmg > app.plist

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
mv CertAid.dmg ${prefix}-${version}${suffix}.dmg
mv app.plist ${prefix}-${version}${suffix}.plist

# Cleanup
rm -rf CertAid.app app.zip