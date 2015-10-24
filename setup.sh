#!/bin/bash

EIX="eix -\*neI --format '<installedversions:NAMEVERSION>' -A"

ROOT=$(cd "$(dirname "${0}")" && pwd)
VERSION=$(<version.txt)
# Merge i386 and x86-64?
MERGE=1

# This defines the arches available and from where to fetch the files
# ARCH:PREFIX
ADM_ARCH=(
    "x86-64:/cross/x86_64-asustor-linux-gnu"
    "i386:/cross/i686-asustor-linux-gnu"
    "arm:/cross/arm-marvell-linux-gnueabi"
)

# Set hostname (ssh) from where to fetch the files
HOST=asustorx

cd "$ROOT"

if [[ ! -d dist ]]; then
    mkdir dist
fi

for arch in "${ADM_ARCH[@]}"; do
    cross=${arch#*:}
    arch=${arch%:*}

    echo "Building ${arch} from ${HOST}:${cross}"

    # Check package versions
    packages=$(<packages.txt)
    echo "# This file is auto-generated." > pkgversions_"$arch".txt
    for package in $packages; do
        version=$(ssh ${HOST} "EIX_PREFIX=${cross} ${EIX} ${package}")
        echo "$version" >> pkgversions_"$arch".txt
    done

    WORK_DIR=build/$arch
    if [ ! -d "$WORK_DIR" ]; then
        mkdir -p "$WORK_DIR"
    fi
    echo "Cleaning out ${WORK_DIR}..."
    rm -rf "$WORK_DIR"
    mkdir "$WORK_DIR"
    chmod 0755 "$WORK_DIR"

    if [ ${MERGE} -eq 0 ]; then
        echo "Copying apkg skeleton..."
        cp -af source/* "$WORK_DIR"
    fi

    echo "Rsyncing files..."
    for file in $(<files.txt); do
        FILEDIR=$(dirname "$file")
        FILEPATH=${FILEDIR#/usr}
        if [ ! -d "${WORK_DIR}${FILEPATH}" ]; then
            mkdir -p "${WORK_DIR}${FILEPATH}"
        fi
        rsync -ra ${HOST}:"${cross}${file}*" "${WORK_DIR}${FILEPATH}/"
    done

    if [ ${MERGE} -eq 0 ]; then
        echo "Finalizing..."
        echo "Setting version to ${VERSION}"
        sed -i '' -e "s^ADM_ARCH^${arch}^" -e "s^APKG_VERSION^${VERSION}^" "$WORK_DIR"/CONTROL/config.json

        echo "Building APK..."
        # APKs require root privileges, make sure priviliges are correct
        sudo chown -R 0:0 "$WORK_DIR"
        sudo scripts/apkg-tools.py create "$WORK_DIR" --destination dist/
        sudo chown -R "$(whoami)" dist

        # Reset permissions on working directory
        sudo chown -R "$(whoami)" "$WORK_DIR"

        echo "Done!"
    fi

done

if [ ! ${MERGE} -eq 0 ]; then
    WORK_DIR=build

    echo "Copying apkg skeleton..."
    cp -af source/* $WORK_DIR

    echo "Finalizing..."
    echo "Setting version to ${VERSION}"
    sed -i '' -e "s^ADM_ARCH^any^" -e "s^APKG_VERSION^${VERSION}^" $WORK_DIR/CONTROL/config.json

    echo "Building APK..."
    # APKs require root privileges, make sure priviliges are correct
    sudo chown -R 0:0 $WORK_DIR
    sudo scripts/apkg-tools.py create $WORK_DIR --destination dist/
    sudo chown -R "$(whoami)" dist

    # Reset permissions on working directory
    sudo chown -R "$(whoami)" $WORK_DIR

    echo "Done!"
fi
