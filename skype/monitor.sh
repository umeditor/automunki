#!/bin/bash -ex

URL=`./skypefinder.sh`

if [ "x${URL}" != "x" ]; then
		echo URL: "${URL}"
        echo "${URL}" > /var/tmp/SkypeURL
fi
