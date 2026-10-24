#!/bin/bash
# Keep the newest N autonamed Clonezilla images on the T7 storage partition.
KEEP=2
T7_UUID="4EC278F1C278DEA1"
MNT=/mnt/storage
LOG=/var/log/clonezilla-prune.log


#write starting line
echo "Pruning starting at $(date -Is)..." >> $LOG


#check if the drive is connected or not
if ! [ -e /dev/disk/by-uuid/$T7_UUID ]; then
        echo " Prune failed. T7 is not connected" >> $LOG
        exit 1
fi


#create a new mounting path
mkdir -p "$MNT"

mount -o rw /dev/disk/by-uuid/$T7_UUID $MNT

if ! mountpoint -q "$MNT"; then
        echo " Prune failed. Mouting not sucessful" >> $LOG
        exit 1
fi



# only prune if the last backup succeeded
if ! tail -1 $MNT/clonezilla-backup.log | grep -q 'exit=0'; then
        echo " Prune failed. Last backup did not report exit=0" >> $LOG
        umount $MNT
        exit 1
fi


#  only prune if the newest image is less than 2  days old

#Find the newest record sort by modification time
NEWEST=$(ls -1dt $MNT/*-img 2>/dev/null | head -1)

#if we can not find any newest record, abort
if [ -z "$NEWEST" ]; then
        echo " Prune failed. No recent image found" >> $LOG
        umount $MNT
        exit 1
fi


#if the newest record is older than 2 days old, abort
if [ -n "$(find "$NEWEST" -maxdepth 0 -mtime +1)" ]; then
        echo " Prune failed. No recent image found" >> $LOG
        umount $MNT
        exit 1
fi


ls -1d $MNT/*-img | sort | head -n -$KEEP | while read d; do
        rm -rf "$d"
        echo "Pruned $(basename "$d")" >> $LOG
done

echo "Prune  done, $(ls -1d $MNT/*-img | wc -l) images kept" >> $LOG
sync
umount $MNT


MNT_clonezilla=/mnt/clonezilla
clonezilla_UID="2693-4721"

echo "Starting pruning osclog..." >> $LOG

#check if the block is there or not
if ! [ -e /dev/disk/by-uuid/$clonezilla_UID ]; then
        echo "Pruning osclog failed. Cannot find drive" >>$LOG
        exit 1
fi

mkdir -p $MNT_clonezilla

#perform mounting and check if mounting works or not
mount -t vfat -o rw /dev/disk/by-uuid/$clonezilla_UID $MNT_clonezilla
if ! mountpoint -q $MNT_clonezilla; then
        echo "Pruning osclog failed. Cannot mount" >> $LOG
        exit 1
fi


ls -1d $MNT_clonezilla/ocslog-* 2>/dev/null | sort | head -n -$KEEP | while read d; do
        rm -rf "$d"
        echo Pruned osclog "$d" >>$LOG
done

echo "Prune osclog done, $(ls -1d $MNT_clonezilla/ocslog-* | wc -l) logs kept" >> $LOG
sync


echo >> $LOG
umount $MNT_clonezilla