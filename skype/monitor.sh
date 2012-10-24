#!/bin/bash -ex

URL=`./skypefinder.sh`

if echo ${URL} | grep -q .dmg; then
	echo URL: "${URL}"
        echo "${URL}" > /var/tmp/SkypeURL
fi
