#!/bin/sh

set -e

if test -n "$NORUN"
then
    exit 0
fi

mkdir -m 0000 /ram-fs
mount -t ramfs -o rw none /ram-fs
mkdir -m 0755 /ram-fs/up /ram-fs/work
mount -t overlay -o lowerdir=/root,upperdir=/ram-fs/up,workdir=/ram-fs/work none /root
