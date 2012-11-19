#!/bin/bash -ex

URL=`./dropboxfinder.sh`

if [ "x${URL}" != "x" ]; then
        echo URL: "${URL}"
        echo "${URL}" > /var/tmp/DropboxDownloadURL
fi
