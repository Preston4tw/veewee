#!/bin/bash

set -o pipefail
set -o errexit
set -o nounset

[ -f /home/${SUDO_USER}/.vbox_version ]
vbox_version="$(cat /home/${SUDO_USER}/.vbox_version)"
[ -d /mnt ]
[ -f /home/${SUDO_USER}/VBoxGuestAdditions_${vbox_version}.iso ]
# Make sure /mnt is unmounted / free for us to use
! mountpoint /mnt &>/dev/null
mount -o loop /home/${SUDO_USER}/VBoxGuestAdditions_${vbox_version}.iso /mnt

# Packages required to build guest additions
# Install the packages after we've got the ISO mounted. No need for the
# packages if we can't mount the ISO...
yum -y install gcc make gcc-c++ kernel-devel zlib-devel openssl-devel \
  readline-devel sqlite-devel perl wget dkms nfs-utils

# MAKE= needed to successfully build OpenGL. No idea how/why this works.
MAKE='/usr/bin/gmake -i' /mnt/VBoxLinuxAdditions.run || true

# Cleanup
umount /mnt

# veewee always copies the guest additions ISO in so we let the cleanup.sh
# script handle its deletion. Commented here in case anyone wonders why.
# rm -f /home/${SUDO_USER}/VBoxGuestAdditions_${vbox_version}.iso

# Remove all the packages and dependencies used to build guest modules
yum -y remove \
  gcc gcc-c++ kernel-devel nfs-utils openssl-devel perl readline-devel \
  sqlite-devel wget zlib-devel cloog-ppl cpp glibc-devel glibc-headers \
  kernel-headers keyutils keyutils-libs-devel krb5-devel libcom_err-devel \
  libevent libgomp libgssglue libselinux-devel libsepol-devel libstdc++-devel \
  libtirpc mpfr ncurses-devel nfs-utils-lib perl-Module-Pluggable \
  perl-Pod-Escapes perl-Pod-Simple perl-libs perl-version ppl python-argparse \
  rpcbind
