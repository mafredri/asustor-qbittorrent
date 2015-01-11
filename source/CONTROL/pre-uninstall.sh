#!/bin/sh

if [ -z $APKG_PKG_DIR ]; then
    PKG_DIR=/usr/local/AppCentral/qbittorrent
else
    PKG_DIR=$APKG_PKG_DIR
fi
