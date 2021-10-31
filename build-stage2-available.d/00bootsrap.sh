#!/bin/bash
#   Copyright (C) 2021 Piotr Chmielnicki
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software Foundation,
#   Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA

set -e
set -x

cd "$(dirname $(readlink -f "${0}"))"/..

if [ "${BUILD_STAGE}" != 2 ]
then
    echo "Error: this script should no be run manually." >&2
    exit -1
fi

debootstrap --arch="${ARCH}" "${DEBIAN_RELEASE}" "${USERLAND_ROOT}" "${DEBIAN_MIRROR}"
cat conf/hostname > "${USERLAND_ROOT}/etc/hostname"
cat conf/sources.list-build > "${USERLAND_ROOT}/etc/apt/sources.list"
sed -i "s,SECMIRROR,${DEBIAN_SECURITY_MIRROR}," "${USERLAND_ROOT}/etc/apt/sources.list"
sed -i "s,MIRROR,${DEBIAN_MIRROR}," "${USERLAND_ROOT}/etc/apt/sources.list"
sed -i "s,RELEASE,${DEBIAN_RELEASE}," "${USERLAND_ROOT}/etc/apt/sources.list"
export DEBIAN_FRONTEND=noninteractive
chroot "${USERLAND_ROOT}" /usr/bin/apt-get update -y
chroot "${USERLAND_ROOT}" /usr/bin/apt-get dist-upgrade -y
