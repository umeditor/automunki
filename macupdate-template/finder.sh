#!/bin/bash

. macupdate.conf

NEWLOC=`curl -I "http://www.macupdate.com/download/${MACUPDATE_APP_ID}" -A 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/536.26.17 (KHTML, like Gecko) Version/6.0.2 Safari/536.26.17' 2>/dev/null | grep Location | sed 's/Location: //' | tr -d '\r'`

if [ "x${NEWLOC}" != "x" ]; then
	echo "${NEWLOC}"
fi
