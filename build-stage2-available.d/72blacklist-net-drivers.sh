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

### Do it properly ... ###
cp conf/net-blacklist.conf "${USERLAND_ROOT}/etc/modprobe.d/"
BLACKLIST="${USERLAND_ROOT}/etc/modprobe.d/net-blacklist.conf" 
for MODULE in $(find "${USERLAND_ROOT}"/usr/lib/modules/*/kernel/drivers/net/ -type f -name '*.ko' -printf '%f#' | sed 's,\.ko#, ,g')
do
    echo "blacklist ${MODULE}" >> "${BLACKLIST}"
done
sort -u -o "${BLACKLIST}" "${BLACKLIST}"

### ... but make sure these module won't be loaded :-) ###
for MODULE in $(find "${USERLAND_ROOT}"/usr/lib/modules/*/kernel/drivers/net/ -type f -name '*.ko')
do
    echo -n '' > "${MODULE}"
done
