#!/bin/bash

URL=`curl -I "http://www.skype.com/go/getskype-macosx" 2>/dev/null | grep Location | sed 's/Location: //' | tr -d '\r'`
count=0

while [ $count -lt 10 ] && ! echo ${URL} | grep -q .dmg; do
  count=$(($count + 1))
  sleep 2
  URL=`curl -I "http://www.skype.com/go/getskype-macosx" 2>/dev/null | grep Location | sed 's/Location: //' | tr -d '\r'`
done

echo "${URL}"
