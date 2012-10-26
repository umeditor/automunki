#!/bin/bash -ex

URL=`./javafinder.rb`

if [ "x${URL}" != "x" ]; then
	echo URL: "${URL}"
        echo "${URL}" > /var/tmp/JavaPluginURL
fi
