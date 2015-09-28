#!/bin/sh

if [ -z "$APKG_PKG_DIR" ]; then
	PKG_DIR=/usr/local/AppCentral/qbittorrent
else
	PKG_DIR=$APKG_PKG_DIR
fi

if [ "$(uname -m)" = "x86_64" ]; then
	AS_NAS_ARCH="x86-64"
else
	AS_NAS_ARCH="i386"
fi

. "${PKG_DIR}/CONTROL/env.sh"

ensure_config_dir() {
	if [ ! -d "${CONFIG}" ]; then
		su - "$USER" -c "mkdir -p '${CONFIG}'"
	fi
}

case "${APKG_PKG_STATUS}" in
	install)
		ensure_config_dir
		su - "$USER" -c "cp '${PKG_DIR}'/config/* '${CONFIG}'/"
		;;
	upgrade)
		# Restore previous qBittorrent configuration if it exists
		if [ -d "${APKG_TEMP_DIR}/config" ]; then
			ensure_config_dir
		    rsync -a "${APKG_TEMP_DIR}/config/" "${CONFIG}/"
		fi
		;;
	*)
		;;
esac

(cd "$PKG_DIR"; for i in $AS_NAS_ARCH/*; do ln -sf "$i" ./; done)

# Install SSL keys (disabled for now...)
#
# if [ ! -d ${CONFIG}/ssl ]; then
#     su - $USER -c "mkdir -p ${CONFIG}/ssl"
#     su - $USER -c "openssl req -new -batch -x509 -nodes -out ${CONFIG}/ssl/server.crt -keyout ${CONFIG}/ssl/server.key"
#     echo "WebUI\\HTTPS\\Certificate=\"@ByteArray($(cat ${CONFIG}/ssl/server.crt))\"" >> ${CONFIG}/qBittorrent.conf
#     echo "WebUI\\HTTPS\\Key=\"@ByteArray($(cat ${CONFIG}/ssl/server.key))\"" >> ${CONFIG}/qBittorrent.conf
# fi
