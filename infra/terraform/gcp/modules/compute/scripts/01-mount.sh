#!/usr/bin/bash

## https://cloud.google.com/compute/docs/disks/format-mount-disk-linux ##

OPT_DEV_NAME="${name}-opt-data"
OPT_DEV_PATH="/dev/disk/by-id/google-$OPT_DEV_NAME"
OPT_MNT_POINT="/opt"

VAR_DEV_NAME="${name}-var-data"
VAR_DEV_PATH="/dev/disk/by-id/google-$VAR_DEV_NAME"
VAR_MNT_POINT="/var"

# Format as ext4 if no filesystem exists
if ! blkid -s TYPE -o value $OPT_DEV_PATH; then
  mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard $OPT_DEV_PATH
fi

if ! blkid -s TYPE -o value $VAR_DEV_PATH; then
  mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard $VAR_DEV_PATH
fi

# update /etc/fstab to mount opt disk to opt dir on reboot
cp /etc/fstab /etc/fstab.backup
OPT_UUID=$(blkid -s UUID -o value $OPT_DEV_PATH)
echo "UUID=$OPT_UUID $OPT_MNT_POINT ext4 defaults,nofail,discard 0 2" >> /etc/fstab

# migrate /var data to new disk
mkdir -p /mnt/newvar
mount $VAR_DEV_PATH /mnt/newvar
rsync -aHXS --info=progress2 /var/ /mnt/newvar/

# update /etc/fstab to mount var disk to var dir on reboot
VAR_UUID=$(blkid -s UUID -o value $VAR_DEV_PATH)
echo "UUID=$VAR_UUID $VAR_MNT_POINT ext4 defaults,nofail,discard 0 2" >> /etc/fstab

# apply mounts defined in /etc/fstab
mount -a
