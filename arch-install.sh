#!/usr/bin/env bash

# --- Arch Linux Encrypted Installation ---

set -euo pipefail

# Variables
lvmpassword="arch"
rootpassword="arch"
username="arch"
userpassword="arch"
hostname="ARCH"
device="/dev/sda"

# Update system and partition
sed -i 's/^#Color/Color/' /etc/pacman.conf
sed -i 's/^#\?ParallelDownloads.*/ParallelDownloads = 1/' /etc/pacman.conf
pacman -Sy --noconfirm

# Partition the disk
parted --script "${device}" -- mklabel gpt \
  mkpart ESP fat32 1Mib 1024MiB \
  set 1 esp on \
  mkpart primary 1024MiB 100%

# Format boot
mkfs.fat -F32 /dev/sda1

# Setup LUKS
echo "$lvmpassword" | cryptsetup --use-random luksFormat /dev/sda2
echo "$lvmpassword" | cryptsetup luksOpen /dev/sda2 cryptlvm

# Setup LVM
pvcreate /dev/mapper/cryptlvm
vgcreate vg0 /dev/mapper/cryptlvm
lvcreate --size 5G -n root vg0
lvcreate --size 1G -n swap vg0
lvcreate -l 100%FREE -n home vg0
lvreduce --size -256M vg0/home

# Format logical volumes
mkfs.ext4 /dev/vg0/root
mkfs.ext4 /dev/vg0/home
mkswap /dev/vg0/swap
swapon /dev/vg0/swap

# Mount partitions
mount /dev/vg0/root /mnt
mount --mkdir /dev/vg0/home /mnt/home
mount --mkdir /dev/sda1 /mnt/boot

# Install base system
pacstrap -K /mnt linux linux-firmware base base-devel vim nano terminus-font efibootmgr lvm2 cryptsetup networkmanager openssh os-prober dosfstools amd-ucode

# Generate fstab
genfstab -U /mnt > /mnt/etc/fstab

# Chroot configuration
arch-chroot /mnt /bin/bash <<EOF
set -euo pipefail

# Timezone and clock
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
hwclock --systohc

# Pacman config
sed -i 's/^#Color/Color/' /etc/pacman.conf
sed -i 's/^#\?ParallelDownloads.*/ParallelDownloads = 1/' /etc/pacman.conf

# Console settings
echo "KEYMAP=fr" > /etc/vconsole.conf
echo "FONT=ter-v28b" >> /etc/vconsole.conf

# Locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Hostname
echo "$hostname" > /etc/hostname

# Root password
echo "root:$rootpassword" | chpasswd

# Create user
useradd -m -s /bin/bash "$username"
echo "$username:$userpassword" | chpasswd
usermod -aG wheel "$username"

# Enable wheel group sudo
sed -i 's/^[[:space:]]*# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# mkinitcpio
sed -i 's/^HOOKS=.*/HOOKS=(base udev keyboard autodetect microcode modconf kms keymap encrypt lvm2 consolefont block encrypt filesystems fsck)/' /etc/mkinitcpio.conf
mkinitcpio -P

# systemd-boot
bootctl install

# LUKS UUID
UUIDcrypt=\$(blkid -o value -s UUID /dev/sda2)

# systemd-boot loader config
cat > /boot/loader/loader.conf <<LOADER
default arch
timeout 5
console-mode max
LOADER

cat > /boot/loader/entries/arch.conf <<ENTRY
title Arch Linux
linux /vmlinuz-linux
initrd /amd-ucode.img
initrd /initramfs-linux.img
options cryptdevice=UUID=\${UUIDcrypt}:lvm:allow-discards resume=/dev/vg0/swap root=/dev/vg0/root rw
ENTRY

# Network services
systemctl enable systemd-networkd
systemctl enable systemd-resolved
systemctl enable NetworkManager
systemctl enable sshd

# Hosts file
cat > /etc/hosts <<HOSTS
127.0.0.1    localhost
::1          localhost
127.0.1.1    $hostname.localdomain    $hostname
HOSTS

echo "Installation and basic configuration complete. Reboot"
EOF
