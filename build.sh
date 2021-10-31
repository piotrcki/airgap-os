#!/usr/bin/env bash
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

BUILD_ENV='/var/airgap-os-build'
DEBIAN_RELEASE='bullseye'
DEFAULT_DEBIAN_MIRROR='https://ftp.debian.org/debian'
DEFAULT_DEBIAN_SECURITY_MIRROR='http://security.debian.org/debian-security'
DEFAULT_ARCH='amd64'

cd "$(dirname $(readlink -f "${0}"))"

hash debootstrap

if [ "${UID}" != 0 ]
then
    echo "Sorry, this script is made to run as root."
    exit -1
fi

if [ -z "${DEBIAN_MIRROR}" ]
then
    DEBIAN_MIRROR="${DEFAULT_DEBIAN_MIRROR}"
fi

if [ -z "${DEBIAN_SECURITY_MIRROR}" ]
then
    DEBIAN_SECURITY_MIRROR="${DEFAULT_DEBIAN_SECURITY_MIRROR}"
fi

if [ -z "${ARCH}" ]
then
    ARCH="${DEFAULT_ARCH}"
fi

rm -rf "${BUILD_ENV}"

debootstrap --arch="${ARCH}" "${DEBIAN_RELEASE}" "${BUILD_ENV}" "${DEBIAN_MIRROR}"
cat conf/hostname > "${BUILD_ENV}/etc/hostname"
mkdir -p -m 0755  "${BUILD_ENV}/usr/local/lib/airgap-os/"
cp -a . "${BUILD_ENV}/usr/local/lib/airgap-os/"

DEBIAN_RELEASE="${DEBIAN_RELEASE}" ARCH="${ARCH}" \
    DEBIAN_MIRROR="${DEBIAN_MIRROR}" DEBIAN_SECURITY_MIRROR="${DEBIAN_SECURITY_MIRROR}" \
    BUILD_STAGE=1 chroot "${BUILD_ENV}" /usr/local/lib/airgap-os/build-stage1.sh

mv "${BUILD_ENV}/output.iso" .
#rm -rf "${BUILD_ENV}"

