#!/bin/bash
# vim:ft=bash.noautoformat

set -e
set -x

cleanup() {
  grep /mnt /proc/mounts | cut -d' ' -f2 | sort -r | xargs umount -R -n || :
  for f in dev sys; do
    [ -d /mnt/$f ] || continue
    mount --make-rslave /mnt/$f || :
    umount -R -n /mnt/$f || :
    sleep 1
  done
  sleep 1
  if grep -q /mnt /proc/mounts; then
    grep /mnt /proc/mounts | cut -d' ' -f2 | sort -r | xargs umount -R -n
  fi
}

if [ ! -e /dev/mapper/void-root ]; then
  cryptsetup luksOpen /dev/sdb3 void
  sleep 1
fi

trap '(sleep 1; cleanup)' 0

if ! grep -q '/dev/mapper/void-root /mnt' /proc/mounts; then
  mount /dev/mapper/void-root /mnt
  mount /dev/mapper/void-home /mnt/home
  mount /dev/sdb2 /mnt/boot

  for f in sys dev proc sys/firmware/efi/efivars; do
    mount --rbind /$f /mnt/$f
  done
fi

PS1='\u@void-chroot \W \$ ' chroot /mnt /bin/bash
