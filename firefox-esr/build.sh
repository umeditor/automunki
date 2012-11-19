#!/bin/bash -ex

# Figure out what the lastest firefox dmg is
moz_url=`ruby firefoxfinder.rb 'http://ftp.mozilla.org/pub/mozilla.org/mozilla.org/firefox/releases/latest-10.0esr/mac/en-US/'`

# download it
ftp -o firefox-original.dmg $moz_url

# convert to RW
hdiutil convert -format UDRW -o firefox-writable.dmg firefox-original.dmg
hdiutil resize -size 1g firefox-writable.dmg

# Mount disk image on temp space
mountpoint=`hdiutil attach -mountrandom /tmp -nobrowse firefox-writable.dmg | awk '/private\/tmp/ { print $3 } '`
echo Mounted on $mountpoint

# Install 
cck_dest="${mountpoint}/Firefox.app/Contents/MacOS/distribution/bundles/izzy-firefox-esr@iss.lsa.umich.edu"
mkdir -p "${cck_dest}"
unzip cck.xpi -d "${cck_dest}"

# Repack down
hdiutil detach $mountpoint
hdiutil convert -format UDZO -o firefox.dmg firefox-writable.dmg

# Build pkginfo
/usr/local/munki/makepkginfo -m go-w -g admin -o root firefox.dmg > firefox.plist

firefox_plist=`pwd`/firefox.plist
# Obtain version info
version=`defaults read "${firefox_plist}" version`

# Change path and other details in the plist
defaults write "${firefox_plist}" installer_item_location "jenkins/Firefox-${version}esr.dmg"
defaults write "${firefox_plist}" minimum_os_version "10.7.0"
defaults write "${firefox_plist}" uninstallable -bool NO

# Make readable by humans
/usr/bin/plutil -convert xml1 firefox.plist
chmod a+r firefox.plist

# Change filenames to suit
mv firefox.dmg Firefox-${version}esr.dmg
mv firefox.plist Firefox-${version}esr.plist

