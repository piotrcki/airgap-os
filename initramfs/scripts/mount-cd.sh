#!/bin/sh

set -e

if [ -n "$NORUN" ]
then
    exit 0
fi

i=0
while true
do
    set +e
    dev="$(blkid -L Airgap-OS)"
    set -e
    if [ -n "${dev}" ]
    then
        break
    fi
    i=$((${i} + 1))
    sleep 0.1
    if [ "${i}" -gt 150 ]
    then
        exit 1
    fi
done

mkdir -m 0000 /cdrom
mount -t iso9660 -o ro "${dev}" /cdrom
