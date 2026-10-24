#!/bin/bash

# The external drive ID for the image storage
T7_UID=4EC278F1C278DEA1

# The mounting path
MNT=/home/partimag

# The log path
LOG=$MNT/clonezilla-backup.log

# Create a mounting path
mkdir -p $MNT

#Check if the external drive exists or not. Check for 30 times for lenient

for i in $(seq 1 30);do
        if   [ -e /dev/disk/by-uuid/$T7_UID ]; then
                break
        fi
        sleep 1
done

#mount that drive to the mounting path
mount -t ntfs-3g /dev/disk/by-uuid/$T7_UID $MNT

#check if the mounting success or not
if ! mountpoint -q $MNT; then
        reboot
        exit 1
fi

echo "Start at $(date -u +%FT%TZ)" >> $LOG

#perform the backup
/usr/sbin/ocs-sr -q2 -j2 -edio -z9p -i 0 -sfsck -sgoc -plu -batch  -p true saveparts autoname nvme0n1p1 nvme0n1p5

Return_status=$?

#write to logs
if [ "$Return_status" -eq 0 ] ; then
        echo "Backup successful at $(date -u +%FT%TZ) with exit=$Return_status" >> $LOG
else
        echo "Backup failed at $(date -u +%FT%TZ) with exit=$Return_status" >> $LOG
fi
sync
umount $MNT
reboot