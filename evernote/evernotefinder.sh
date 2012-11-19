#!/bin/bash

curl -I "http://evernote.com/download/get.php?file=EvernoteMac" 2>/dev/null | grep Location | sed 's/Location: //' | tr -d '\r'

