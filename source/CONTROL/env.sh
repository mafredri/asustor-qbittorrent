#!/bin/sh

PACKAGE=qbittorrent
PKG_DIR=/usr/local/AppCentral/${PACKAGE}

USER=admin
GROUP=administrators
HOME=$(getent passwd "${USER%:*}" | cut -d ':' -f 6)
CONFIG="${HOME}/.config/qBittorrent"

PATH="${PKG_DIR}/bin:$PATH"
PATH="${PKG_DIR}/usr/bin:$PATH"
LD_LIBRARY_PATH="${PKG_DIR}/lib:${LD_LIBRARY_PATH}"
LD_LIBRARY_PATH="${PKG_DIR}/lib64:${LD_LIBRARY_PATH}"
LD_LIBRARY_PATH="${PKG_DIR}/usr/lib:${LD_LIBRARY_PATH}"
LD_LIBRARY_PATH="${PKG_DIR}/usr/lib64:${LD_LIBRARY_PATH}"
export HOME USER GROUP PATH LD_LIBRARY_PATH
