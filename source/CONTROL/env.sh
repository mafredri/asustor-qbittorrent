#!/bin/sh

PACKAGE=qbittorrent
PKG_DIR=/usr/local/AppCentral/${PACKAGE}

USER=admin
GROUP=administrators
HOME=$(getent passwd "${USER%:*}" | cut -d ':' -f 6)
CONFIG="${HOME}/.config/qBittorrent"

export HOME USER GROUP
