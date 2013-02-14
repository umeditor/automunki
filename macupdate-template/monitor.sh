#!/bin/bash -ex

URL=`./finder.sh`

if [ "x${URL}" != "x" ]; then
        echo URL: "${URL}"
        echo "${URL}" > $1
fi
