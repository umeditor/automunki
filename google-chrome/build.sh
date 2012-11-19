#!/bin/bash -ex

# download it
curl -o googlechrome.dmg https://dl.google.com/chrome/mac/stable/GGRM/googlechrome.dmg

# Mount disk image on temp space
#mountpoint=`hdiutil attach -mountrandom /tmp -nobrowse googlechrome.dmg | awk '/private\/tmp/ { print $3 } '`
#echo Mounted on $mountpoint

# Build pkginfo
plist=`pwd`/googlechrome.plist
/usr/local/munki/makepkginfo -m go-w -g admin -o root googlechrome.dmg > "${plist}"

# Obtain version info
version=`defaults read "${plist}" version`

# Change path and other details in the plist
defaults write "${plist}" installer_item_location "jenkins/Google-Chrome-${version}.dmg"
defaults write "${plist}" name "Chrome"
defaults write "${plist}" minimum_os_version "10.7.0"
defaults write "${plist}" uninstallable -bool NO

# Make readable by humans
/usr/bin/plutil -convert xml1 "${plist}"
chmod a+r "${plist}"

# Change filenames to suit
mv googlechrome.dmg Google-Chrome-${version}.dmg
mv "${plist}" Google-Chrome-${version}.plist

