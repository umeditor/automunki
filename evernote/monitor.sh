#!/bin/bash -ex

URL=`./evernotefinder.sh`

if [ "x${URL}" != "x" ]; then
        echo URL: "${URL}"
        echo "${URL}" > /var/tmp/EvernoteDownloadURL
fi
