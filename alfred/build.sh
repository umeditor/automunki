#!/bin/bash -ex

# CONFIG
prefix="Alfred"
suffix=""
package_name="Alfred"
url=`ruby ~/automunki/alfred/find-alfred.rb 'http://www.alfredapp.com/'`

# download it
curl -o app.zip $url
unzip app.zip
hdiutil create -srcfolder Alfred.app Alfred.dmg
# Build pkginfo
/usr/local/munki/makepkginfo -m go-w -g admin -o root Alfred.dmg > app.plist

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
mv Alfred.dmg ${prefix}-${version}${suffix}.dmg
mv app.plist ${prefix}-${version}${suffix}.plist

