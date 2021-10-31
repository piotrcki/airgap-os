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

cat conf/lightdm.conf > "${USERLAND_ROOT}/etc/lightdm/lightdm.conf"
cp  conf/80_mate-airgap-os.gschema.override "${USERLAND_ROOT}/usr/share/glib-2.0/schemas/"
cp  misc/airgap-os-backgroung.jpg "${USERLAND_ROOT}/usr/share/images/"
chroot "${USERLAND_ROOT}" /usr/bin/glib-compile-schemas /usr/share/glib-2.0/schemas
