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
apt-get install golang build-essential -y
chroot "${USERLAND_ROOT}" /usr/bin/apt-get install zenity -y
unset DEBIAN_FRONTEND
rm -rf /tmp/crypt0 /tmp/sign0
mkdir -m 0700 /tmp/crypt0 /tmp/sign0
tar xf misc/crypt0.tar.xz -C /tmp/crypt0/
tar xf misc/sign0.tar.xz -C /tmp/sign0/
make -C /tmp/crypt0 all
make -C /tmp/sign0  all
cp /tmp/crypt0/*/*.desktop "${USERLAND_ROOT}/usr/share/applications/"
cp /tmp/crypt0/encrypt0/encrypt0 \
    /tmp/crypt0/encrypt0/encrypt0-gui \
    /tmp/crypt0/decrypt0/decrypt0 \
    /tmp/crypt0/decrypt0/decrypt0-gui \
    /tmp/crypt0/genpads0/genpads0 \
    /tmp/sign0/sign0/sign0 \
    /tmp/sign0/verify0/verify0 \
    /tmp/sign0/gensigkeys0/gensigkeys0 \
    "${USERLAND_ROOT}/usr/bin/"
