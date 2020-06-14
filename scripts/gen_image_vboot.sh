#!/usr/bin/env bash
# Copyright (C) 2021 OpenWrt.org
set -e -x
[ $# == 6 ] || {
    echo "SYNTAX: $0 <file> <bootpart size> <kernel size> <kernel image> <rootfs size> <rootfs image>"
    exit 1
}

OUTPUT="$1"
BOOTPARTSIZE="$2"
KERNELSIZE="$3"
KERNELIMAGE="$4"
ROOTFSSIZE="$5"
ROOTFSIMAGE="$6"

rm -f "${OUTPUT}"

head=16
sect=63

# create partition table
set $(ptgen -o "${OUTPUT}" -h $head -s $sect -g -p ${BOOTPARTSIZE}m -T cros_kernel -p ${KERNELSIZE}m -p ${ROOTFSSIZE}m)

BOOTOFFSET="$(($1 / 512))"
BOOTSIZE="$2"
KERNELOFFSET="$(($3 / 512))"
KERNELSIZE="$4"
ROOTFSOFFSET="$(($5 / 512))"
ROOTFSSIZE="$(($6 / 512))"

mkfs.fat -n boot -C "${OUTPUT}.boot" -S 512 "$((BOOTSIZE / 1024))"

dd if="${OUTPUT}.boot" of="${OUTPUT}" bs=512 seek="${BOOTOFFSET}" conv=notrunc
rm -f "${OUTPUT}.boot"
dd if="${KERNELIMAGE}" of="${OUTPUT}" bs=512 seek="${KERNELOFFSET}" conv=notrunc
dd if="${ROOTFSIMAGE}" of="${OUTPUT}" bs=512 seek="${ROOTFSOFFSET}" conv=notrunc
