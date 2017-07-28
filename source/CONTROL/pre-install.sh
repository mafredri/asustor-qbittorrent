#!/bin/sh

if [ -z "$APKG_PKG_DIR" ]; then
	PKG_DIR=/usr/local/AppCentral/qbittorrent
else
	PKG_DIR=$APKG_PKG_DIR
fi


case "${APKG_PKG_STATUS}" in
	install)
		;;
	upgrade)
		. "${PKG_DIR}/CONTROL/env.sh"

		# Back up qBittorrent configuration
		if [ -d "${CONFIG}" ]; then
			mkdir "${APKG_TEMP_DIR}/config"
			rsync -a "${CONFIG}/" "${APKG_TEMP_DIR}/config/"
		fi
		;;
	*)
		;;
esac

exit 0
