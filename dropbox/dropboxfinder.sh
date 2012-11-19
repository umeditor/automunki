#!/bin/bash

NEWLOC=`curl -I "https://www.dropbox.com/download?plat=mac" 2>/dev/null | grep location | sed 's/location: //' | tr -d '\r'`

if [ "x${NEWLOC}" != "x" ]; then
	echo "${NEWLOC}"
fi
