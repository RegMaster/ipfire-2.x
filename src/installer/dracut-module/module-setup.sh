#!/bin/bash
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

# called by dracut
check() {
    return 255
}

# called by dracut
depends() {
    echo base bash mdraid shutdown
    return 0
}

# called by dracut
install() {
    inst /etc/system-release
    inst /usr/bin/installer
    inst /usr/bin/downloadsource.sh
    inst /usr/local/bin/iowrap

    # Kernel drivers
    instmods =drivers/hid

    # Network drivers
    instmods =drivers/net/ethernet =drivers/net/usb
    instmods virtio_net hv_netvsc vmxnet3

    # Filesystem support
    inst_multiple parted mkswap mke2fs mkreiserfs mkfs.xfs
    instmods ext4 iso9660 reiserfs vfat xfs

    # Extraction
    inst_multiple tar gzip lzma xz

    # Networking
    inst_multiple dhcpcd ethtool hostname ip ping wget
    inst /usr/bin/start-networking.sh
    inst /var/ipfire/dhcpc/dhcpcd-run-hooks
    inst /var/ipfire/dhcpc/dhcpcd.conf
    for file in /var/ipfire/dhcpc/dhcpcd-hooks/*; do
        inst "${file}"
    done
    inst "$moddir/70-dhcpcd.exe" "/var/ipfire/dhcpc/dhcpcd-hooks/70-dhcpcd.exe"

    # Misc. tools
    inst_multiple cut grep eject killall md5sum touch
    inst_multiple -o fdisk cfdisk df ps top

    # Hardware IDs
    inst /usr/share/hwdata/pci.ids /usr/share/hwdata/usb.ids

    # Locales
    for locale in de en es fr nl pl ru tr; do
        for file in $(find /usr/lib/locale/${locale}*); do
            inst "${file}"
        done
    done
    for file in /usr/share/locale/*/LC_MESSAGES/installer.mo; do
        inst "${file}"
    done

    # Bash start files
    inst_multiple /etc/profile /root/.bash_profile /etc/bashrc /root/.bashrc
    for file in /etc/profile.d/*.sh; do
        inst "${file}"
    done

    inst_hook cmdline 99 "$moddir/fake-root.sh"
    inst_hook pre-mount 99 "$moddir/run-installer.sh"

    return 0
}