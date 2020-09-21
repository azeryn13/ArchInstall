#! /bin/bash

# Tom's Arch Linux Installation Script.

echo "Tom's Arch Linux Installer"

# Set up network connection
read -p 'Are you connected to internet? [y/N]: ' neton
if ! [ $neton = 'y' ] && ! [ $neton = 'Y' ]
then 
    echo "Connect to internet to continue..."
    exit
fi

echo "Updating the system clock"
timedatectl set-ntp true

# Filesystem mount warning
echo "Delete all partitions, create, and format the partitions"
read -p 'Continue? [y/N]: ' fsok
if ! [ $fsok = 'y' ] && ! [ $fsok = 'Y' ]
then 
    echo "Edit the script to continue..."
    exit
fi

# create the partitions 
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk -1
  d #
    #
  d #
    #
  d #
    #
  d #
    #
  o # clear the in memory partition table
  n # new partition
  p # primary partition
  1 # partition number 1
    # default - start at beginning of disk 
  +512M # 512 MB boot parttion
  n # new partition
  p # primary partition
  2 # partion number 2
    # default, start immediately after preceding partition
    # default, extend partition to end of disk
  a # make a partition bootable
  1 # bootable partition is partition 1 -- /dev/sda1
  p # print the in-memory partition table
  w # write the partition table
  q # and we're done
EOF

# Format the partitions
mkfs.ext4 /dev/sda2
mkfs.fat -F32 /dev/sda1
read -p "Press any key to resume ..."

# Mount the file systems
mount /dev/sda2 /mnt
mkdir -pv /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi
read -p "Press any key to resume ..."

# Install Arch Linux
echo "Starting install.."
pacstrap /mnt base linux linux-firmware

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Copy post-install system cinfiguration script to new /root
cp -rfv post-install.sh /mnt/root
chmod a+x /mnt/root/post-install.sh

# Chroot
arch-chroot /mnt

# Finish
echo "Arch Linux system installed."
echo "The only thing left is to reboot into the new system."
#read tmpvar
#reboot