# Automatic image backup with clonezilla

## Setting up clonezilla for auto backup upon booting up

1. Mount to clonezilla boot partition 

```bash
sudo mount -t vfat -o rw /dev/disk/by-uuid/****-**** /mnt/clonezilla
```
2. Write a backup job script 

Pseudocode:
- check if the drive that stores the image exists or not
- mount the drive to the mounting directory
- check if the mounting point success or not
- Start the backup command
```bash
/usr/sbin/ocs-sr -q2 -j2 -edio -z9p -i 0 -sfsck -sgoc -plu -batch  -p true saveparts autoname nvme0n1p1 nvme0n1p5
```
(See docs/04_full_image_backup.md) for references
- Write to log
- Unmount and reboot

(The actual script can be seen at /scripts/backup/backup-jobs.sh):

3. Add auto backup entry upon booting for clonezilla

Edit the grub.cfg file at mnt/clonezilla/boot/grub/grub.cfg

Add the entry in the entries menu
```bash
menuentry "AUTO BACKUP: image Ubuntu to storage, then reboot" --id auto-backup {
  search --set -f /live/vmlinuz
  $linux_cmd /live/vmlinuz boot=live union=overlay username=user config loglevel=3 hostname=cl-20260913-r noswap edd=on nomodeset enforcing=0 noeject locales=en_US.UTF-8 keyboard-layouts=us ocs_live_run="bash /run/live/medium/backup-job.sh" ocs_live_extra_param="" ocs_live_batch="yes" vga=788 net.ifnames=0 quiet splash i915.blacklist=yes radeonhd.blacklist=yes nouveau.blacklist=yes vmwgfx.enable_fbdev=1 ocs_1_cpu_udev scsi_mod.use_blk_mq=0 nvme.poll_queues=1
  $initrd_cmd /live/initrd.img                                                         }
```

## Setting up automation script on server side

1. Setting up the trigger script in "/usr/local/bin/clonezilla-trigger.sh"

Pseudocode
- Identify the UUID for clonezilla boot partition and image drive
- check if those drives exist or not
- Boot one time into clonezilla boot partition and then boot normal next time
- Write log 
(See docs/clonezilla-trigger.sh for scripts)

2. Setting up the prune script in "/usr/local/bin/clonezilla-prune.sh"

Goal: Keep the 2 newest backup (prune in image storage)

Pseudocode: 
- Check if the mounting is succesful or not
- Set conditions for pruning:
    - Only prune if the newest image is less than 2 days old
    - Only prune if the last backup succcess
- Sort the images by modification time
- Prune all images except the 2 newest one

Goal: Keep the 2 newest log on clonezilla boot partition

Pseudocode:
- Check if mounting to clonezilla boot partition is successful or not
- Sort all logs by modification time
- Prune all logs except the the 2 newest one

(See docs/clonezilla-prune.sh for scripts)


## Setting up automation using crontab

Setting up clonezilla-trigger.sh for daily backup
```bash
00 23 * * * /usr/local/bin/clonezilla-trigger.sh
```

Setting up prune 10 minutes after backup
```bash
10 23 * * * /usr/local/bin/clonezilla-prune.sh
```