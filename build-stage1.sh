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

USERLAND_ROOT='/userland'

cd "$(dirname $(readlink -f "${0}"))"

if [ "${BUILD_STAGE}" != 1 ]
then
    echo "Error: this script should no be run manually." >&2
    exit -1
fi

### Bootstrap ###
cat conf/sources.list-build > /etc/apt/sources.list
sed -i "s,SECMIRROR,${DEBIAN_SECURITY_MIRROR}," /etc/apt/sources.list
sed -i "s,MIRROR,${DEBIAN_MIRROR}," /etc/apt/sources.list
sed -i "s,RELEASE,${DEBIAN_RELEASE}," /etc/apt/sources.list
apt-get update -y
apt-get dist-upgrade -y
apt-get install genisoimage isolinux syslinux-utils syslinux-efi dosfstools \
     fusefat squashfs-tools debootstrap parted git -y
mkdir -p -m 0700 "${USERLAND_ROOT}" /iso-content

### Setup userland  ###
stage2="$(find ./build-stage2-enabled.d -type l,f | sort)"
for script in ${stage2}
do
    DEBIAN_RELEASE="${DEBIAN_RELEASE}" ARCH="${ARCH}" DEBIAN_MIRROR="${DEBIAN_MIRROR}" \
    USERLAND_ROOT="${USERLAND_ROOT}" BUILD_STAGE=2 "$script"
done

### Setup legacy BIOS boot ###
cp /usr/lib/ISOLINUX/isolinux.bin \
    /usr/lib/syslinux/modules/bios/ldlinux.c32 \
    "${USERLAND_ROOT}/vmlinuz" \
    "${USERLAND_ROOT}/initrd.img" \
    conf/syslinux.cfg \
    /iso-content/

### Setup UEFI boot ###
EFI_OPTS=''
if [ "${ARCH}" = 'amd64' ]
then
    mknod /dev/fuse c 10 229
    mkdir -m 0000 /esp
    head -c 48M /dev/zero > /iso-content/efi64.img
    mkfs.fat --mbr=y -F 16 /iso-content/efi64.img
    fusefat -o rw+ /iso-content/efi64.img /esp
    mkdir -p /esp/EFI/BOOT
    cp /usr/lib/syslinux/modules/efi64/ldlinux.e64 /esp/EFI/BOOT/
    cp /usr/lib/SYSLINUX.EFI/efi64/syslinux.efi /esp/EFI/BOOT/BOOTX64.EFI
    cp "${USERLAND_ROOT}/vmlinuz" \
        "${USERLAND_ROOT}/initrd.img" \
        conf/syslinux.cfg /esp/
    sync
    umount /esp
    EFI_OPTS='-eltorito-alt-boot -e efi64.img -no-emul-boot'
fi

### Pack all together ###
mksquashfs "${USERLAND_ROOT}" /iso-content/filesystem.squashfs -comp xz -Xdict-size 100%
genisoimage -J -joliet-long -o /output.iso -b isolinux.bin  \
    -no-emul-boot -boot-load-size 4 -boot-info-table $EFI_OPTS -c boot.cat \
    -V Airgap-OS /iso-content

if [ -n "${EFI_OPTS}" ]
then
    isohybrid --uefi /output.iso
    parted /output.iso resizepart 2 49MiB
else
    isohybrid /output.iso
fi
