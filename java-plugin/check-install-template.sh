#!/bin/bash

# Swapped by perl
plugin_version=PLUGIN_VERSION

current_bundle=`defaults read "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Info" CFBundleIdentifier`
current_version=`defaults read "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Info" CFBundleVersion`

# Not Oracle: install
if [ "${current_bundle}" != "com.oracle.java.JavaAppletPlugin" ]; then
  exit 0
else
  if [ ${current_version:-0} \< ${plugin_version} ]; then
    # Version out of date: install
    exit 0
  else
    # Current installed version same or higher
    exit 1
  fi
fi
