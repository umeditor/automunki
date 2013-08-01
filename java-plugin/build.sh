#!/bin/bash -ex

# CONFIG
prefix="OracleJavaPlugin"
suffix=""
package_name="OracleJavaPlugin"
url=`ruby ./javafinder.rb`

# download it
curl -L -o app.dmg $url

# Mount it to extract some files
mountpoint=`hdiutil attach -mountrandom /tmp -nobrowse app.dmg | awk '/private\/tmp/ { print $NF } '`
mkdir -p "build-root/Library/Internet Plug-Ins/JavaAppletPlugin.plugin"

pkgutil --expand "${mountpoint}"/Java*pkg flat-pack
pwd=`pwd`

for payload in `find flat-pack -name 'Payload'`; do
        echo $payload
        (cd "build-root/Library/Internet Plug-Ins/JavaAppletPlugin.plugin"; pax -rz -f "${pwd}/$payload")
done

hdiutil detach "$mountpoint"

# Obtain version info
plugin_version=`defaults read "${pwd}/build-root/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Info" CFBundleVersion`
package_version=`echo ${plugin_version} | perl -p -e 's/^\d\.//'`

# Write installcheck script
cp check-install-template.sh installcheck.sh
perl -p -i -e "s/PLUGIN_VERSION/$plugin_version/" installcheck.sh

# Build pkginfo
/usr/local/munki/makepkginfo -m go-w -g admin -o root --preinstall_script=installcheck.sh app.dmg > app.plist

plist=`pwd`/app.plist

# Remove "build-root" from file paths, rename script to installcheck
perl -p -i -e 's/build-root//' app.plist
perl -p -i -e 's/preinstall_script/installcheck_script/' app.plist


# Change path and other details in the plist
defaults write "${plist}" installer_item_location "${prefix}-${package_version}${suffix}.dmg"
defaults write "${plist}" minimum_os_version "10.7.3"
defaults write "${plist}" uninstallable -bool NO
defaults write "${plist}" name "${package_name}"
defaults write "${plist}" display_name "Oracle Java PlugIn"
defaults write "${plist}" version "$package_version"

# Make readable by humans
/usr/bin/plutil -convert xml1 "${plist}"
chmod a+r "${plist}"

# Change filenames to suit
mv app.dmg   ${prefix}-${package_version}${suffix}.dmg
mv app.plist ${prefix}-${package_version}${suffix}.plist

