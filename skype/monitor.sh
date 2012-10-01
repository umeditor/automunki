#!/bin/bash

URL=`./skypefinder.sh`

if [ "x${URL}" != "x" ]; then
        echo "${URL}" > /var/tmp/SkypeURL
fi
