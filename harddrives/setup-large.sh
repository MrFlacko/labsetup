## /dev/sda is Raid5 4 drives
## /dev/sdb is Raid5 6 drives

## lsblk 
# NAME                      MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
# sda                         8:0    0   7.3T  0 disk 
# sdb                         8:16   0   2.7T  0 disk 
# sdc                         8:32   0 136.1G  0 disk 
# ├─sdc1                      8:33   0     1G  0 part /boot/efi
# ├─sdc2                      8:34   0     2G  0 part /boot
# └─sdc3                      8:35   0 133.1G  0 part 
#   └─ubuntu--vg-ubuntu--lv 252:0    0  66.5G  0 lvm  /

# Setup
sudo wipefs -a /dev/sda /dev/sdb
sudo pvcreate /dev/sda /dev/sdb
sudo vgcreate vgdata /dev/sda /dev/sdb
sudo lvcreate -l 100%FREE -n big vgdata
sudo mkfs.xfs /dev/vgdata/big # xfs better for big drives

# Mounting
sudo mkdir /mnt/big
echo '/dev/vgdata/big /mnt/big xfs defaults,noatime 0 0' | sudo tee -a /etc/fstab
sudo mount -a

## lsblk
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
