#!/bin/bash -ex

url="https://sync.box.com/static/sync/release/BoxSyncMac.zip"

# download it
curl $url | md5 > /var/tmp/BoxSyncMD5
