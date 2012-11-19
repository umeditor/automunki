#!/bin/bash

# Delete old versions
rm -rf '/Applications/Adobe/Flash Player/AddIns/airappinstaller'
rm -rf '/Applications/Utilities/Adobe AIR Application Installer.app'
rm -rf '/Applications/Utilities/Adobe AIR Uninstaller.app'
rm -rf '/Users/Shared/Library/Application Support/Adobe/AIR'

# Old attempt cleanup
rm -rf '/Library/Application Support/Adobe/Adobe AIR Installer.app'

# Copy installer app
rsync -avE '/Library/Frameworks/Adobe AIR.framework/Versions/Current/Adobe AIR Application Installer.app' '/Applications/Utilities'

# Add config to make installer app be able to open .air files
defaults write '/Applications/Utilities/Adobe AIR Application Installer.app/Contents/Info.plist' 'CFBundleDocumentTypes' '( { CFBundleTypeExtensions = ( "air" ); CFBundleTypeIconFile = "Adobe AIR Installer Package.icns"; CFBundleTypeMIMETypes = ( "application/vnd.adobe.air-application-installer-package+zip" ); CFBundleTypeName = "com.adobe.air.InstallerPackage"; CFBundleTypeRole = Viewer; } )'
plutil -convert xml1 '/Applications/Utilities/Adobe AIR Application Installer.app/Contents/Info.plist'
chmod a+r '/Applications/Utilities/Adobe AIR Application Installer.app/Contents/Info.plist'

# I heard you like plugins so I put a plugin in your plugin
mkdir -p '/Applications/Adobe/Flash Player/AddIns/airappinstaller'
cp '/Library/Frameworks/Adobe AIR.framework/Resources/airappinstaller'      '/Applications/Adobe/Flash Player/AddIns/airappinstaller'
cp '/Library/Frameworks/Adobe AIR.framework/Resources/airappinstaller.rsrc' '/Applications/Adobe/Flash Player/AddIns/airappinstaller/airappinstaller/..namedfork/rsrc'
cp '/Library/Frameworks/Adobe AIR.framework/Resources/digest.s'             '/Applications/Adobe/Flash Player/AddIns/airappinstaller'

