#!/bin/sh

PACKAGE=qbittorrent
PKG_DIR=/usr/local/AppCentral/${PACKAGE}

USER=admin
GROUP=administrators
HOME=$(getent passwd "${USER%:*}" | cut -d ':' -f 6)
CONFIG=${HOME}/.config/qBittorrent

export PATH=${PKG_DIR}/bin:$PATH
export LD_LIBRARY_PATH=${PKG_DIR}/lib:${PKG_DIR}/lib/qt4:${LD_LIBRARY_PATH}
export HOME USER GROUP
