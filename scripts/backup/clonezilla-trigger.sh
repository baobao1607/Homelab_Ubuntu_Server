#!/bin/bash
# Reboot once into the T7's Clonezilla AUTO entry via Ubuntu's GRUB.
LOG=/var/log/clonezilla-trigger.log
T7_UUID="4EC278F1C278DEA1"   # storage partition (sda1)
CZ_UUID="2693-4721"          # Clonezilla partition (sda2)

echo "$(date -Is) starting backup service..." >> $LOG

#check if both drive exists or not
if [ ! -e /dev/disk/by-uuid/$T7_UUID ] || [ ! -e /dev/disk/by-uuid/$CZ_UUID ]; then
  echo "SKIP service: T7 not connected, normal reboot" >> $LOG
  /sbin/reboot
  exit 1
fi


if grub-reboot clonezilla-t7; then
  echo "booting into clonezilla-t7, rebooting" >> $LOG
else
  echo "grub-reboot FAILED, normal reboot executed" >> $LOG
fi
echo >> $LOG
/sbin/reboot
~