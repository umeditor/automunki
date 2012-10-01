#!/bin/bash

NEWLOC=`curl -I "http://www.skype.com/go/getskype-macosx" 2>/dev/null | grep Location | sed 's/Location: //' | tr -d '\r'`

if [ "x${NEWLOC}" != "x" ]; then
        echo "${NEWLOC}"
fi
