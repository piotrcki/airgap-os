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
export DEBIAN_FRONTEND=noninteractive
chroot "${USERLAND_ROOT}" /usr/bin/apt-get purge rsyslog \
    network-manager network-manager-gnome -y
cat conf/sources.list-final > "${USERLAND_ROOT}/etc/apt/sources.list"
chroot "${USERLAND_ROOT}" /usr/bin/apt-get update -y
chroot "${USERLAND_ROOT}" /usr/bin/apt-get clean  -y
rm -rf "${USERLAND_ROOT}"/var/log/*
