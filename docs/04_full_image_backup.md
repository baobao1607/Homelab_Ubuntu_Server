# Full Image Backup on Ubuntu Server

## Install Clonezilla Live on external drive
1. Download Clonezilla ISO files from https://clonezilla.org/downloads.php

2. Create a FAT32 volume of 1GB on external drive

3. Unzip and move to that volume 


## Boot Clonezilla on laptop
1. Plugged the external drive in, go to Boot Menu with F12

2. Choose Clonezilla live, option 1

3. Choose the drive to save image to

4. Choose the folder in that drive (or let default)

5. Choose saveparts

6. Create an image name --> choose the partition --> compression mode --> action when finished


## Next time backup the full image

Use this command on the Clonezilla CLI for easier use
```bash
/usr/sbin/ocs-sr -q2 -c -j2 -edio -z9p -i 0 -sfsck -sgoc -plu -p poweroff saveparts "homelab_2026-10-20" nvme0n1p1 nvme0n1p5
```

Explain of the parameters + flags:
- -q2: partclone (copy only used blocks)
- -c: ask for confirmation before executing
- -z9p: compression mode
- -i 0: (do not split the image into chunks)
- -p poweroff: power off when finished
- saveparts <name_of_image> <which_parts>
