#!/usr/bin/env bash

DISK_DEV=${disk_dev}
DISK_MOUNTPOINT="/mnt/data"
CONFIG_DIR="/mnt/config"

# Make sure that all of the EBS block devices exist. Waits up to 5 minutes.
while [ ! -b $DISK_DEV ]
do
  ((ctr++)) && ((ctr == 30)) && echo "Gave up waiting for block device" && exit 1
  echo "* Waiting for block device to be created."
  ls /dev/xd* /dev/sd*
  sleep 10
done

echo "* Block devices is available."
if ! [ -z "$(blkid -o value -s TYPE $DISK_DEV)" ]; then
    echo "* Disk device unexpectedly has a filesystem already."
    exit 1
fi

# Exit immediately if a command exits with a non-zero status past this point
set -e

echo "* Formatting EBS block device"
mkfs.ext4 -m0 $DISK_DEV

echo "* Creating /etc/fstab entry"
echo "$DISK_DEV  $DISK_MOUNTPOINT  ext4  defaults  0  2" >> /etc/fstab
cat /etc/fstab

echo "* Mounting EBS volume"
mkdir -p $DISK_MOUNTPOINT
mkdir -p $CONFIG_DIR
mount $DISK_MOUNTPOINT
