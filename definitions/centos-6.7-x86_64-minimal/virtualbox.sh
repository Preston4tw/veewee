#!/bin/bash

set -o pipefail
set -o errexit
set -o nounset

# VirtualBox Guest Additions
[ -f /home/${SUDO_USER}/.vbox_version ]
vbox_version="$(cat /home/${SUDO_USER}/.vbox_version)"
[ -d /mnt ]
[ -f /home/${SUDO_USER}/VBoxGuestAdditions_${vbox_version}.iso ]
## Make sure /mnt is unmounted / free for us to use
! mountpoint /mnt &>/dev/null
mount -o loop /home/${SUDO_USER}/VBoxGuestAdditions_${vbox_version}.iso /mnt

## Packages required to build guest additions
## Install the packages after we've got the ISO mounted. No need for the
## packages if we can't mount the ISO...
yum -y install gcc make gcc-c++ kernel-devel zlib-devel openssl-devel \
  readline-devel sqlite-devel perl wget dkms nfs-utils

## MAKE= needed to successfully build OpenGL. No idea how/why this works.
MAKE='/usr/bin/gmake -i' /mnt/VBoxLinuxAdditions.run || true

## Cleanup
umount /mnt

## veewee always copies the guest additions ISO in so we let the cleanup.sh
## script handle its deletion. Commented here in case anyone wonders why.
## rm -f /home/${SUDO_USER}/VBoxGuestAdditions_${vbox_version}.iso

## Remove all the packages and dependencies used to build guest modules
yum -y remove \
  gcc gcc-c++ kernel-devel nfs-utils openssl-devel perl readline-devel \
  sqlite-devel wget zlib-devel cloog-ppl cpp glibc-devel glibc-headers \
  kernel-headers keyutils keyutils-libs-devel krb5-devel libcom_err-devel \
  libevent libgomp libgssglue libselinux-devel libsepol-devel libstdc++-devel \
  libtirpc mpfr ncurses-devel nfs-utils-lib perl-Module-Pluggable \
  perl-Pod-Escapes perl-Pod-Simple perl-libs perl-version ppl python-argparse \
  rpcbind

# https://www.virtualbox.org/ticket/7619
# Add kernel option nolapic_timer to fix poor performance when using multiple
# CPUs in the guest. This issue appears to be a combination of how the CentOS 6
# kernel is compiled and some kind of possible regression in the timer with
# VirtualBox when the guest thinks its running on bare metal. I've noticed that
# NixOS does not have this problem and is compiled with several kernel options
# turned on that detect when the kernel is running as a guest. This option might
# not be needed if the CentOS kernel is compiled with these options.
if ! grep -q '^[[:space:]]\+kernel .*nolapic_timer' /boot/grub/grub.conf; then
  sed -i --follow-symlinks 's/^\([[:space:]]\+kernel .*\)/\1 nolapic_timer/' /boot/grub/grub.conf
fi
