##lsblk
# NAME                      MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
# sda                         8:0    0   7.3T  0 disk 
# └─vgdata-big              252:1    0    10T  0 lvm  /mnt/big
# sdb                         8:16   0   2.7T  0 disk 
# └─vgdata-big              252:1    0    10T  0 lvm  /mnt/big
# sdc                         8:32   0 136.1G  0 disk 
# ├─sdc1                      8:33   0     1G  0 part /boot/efi
# ├─sdc2                      8:34   0     2G  0 part /boot
# └─sdc3                      8:35   0 133.1G  0 part 
#   └─ubuntu--vg-ubuntu--lv 252:0    0  66.5G  0 lvm  /
# sdd                         8:48   0   5.5T  0 disk 
# ├─sdd1                      8:49   0    16M  0 part 
# └─sdd2                      8:50   0   5.5T  0 part 

## ntfs-3g required but already installed
echo '/dev/sdd2 /mnt/6TB\040Drive ntfs defaults,noatime 0 0' | sudo tee -a /etc/fstab
