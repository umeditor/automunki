#!/bin/bash -ex

URL=`./javafinder.rb`

if echo ${URL} | grep -q .dmg; then
	echo URL: "${URL}"
        echo "${URL}" > /var/tmp/JavPluginURL
fi
