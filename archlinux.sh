#!/usr/bin/env bash

# --- Arch Linux Installation ---

set -euo pipefail

# Variables
rootpassword="arch"
username="sh"
userpassword="arch"
hostname="ARCH"
device="/dev/vda"
EFI="/dev/vda1"
ROOT="/dev/vda2"

# Update system and partition
sed -i 's/^#Color/Color/' /etc/pacman.conf
sed -i 's/^#\?ParallelDownloads.*/ParallelDownloads = 1/' /etc/pacman.conf
pacman -Sy --noconfirm

# Partition the disk
parted --script "${device}" -- mklabel gpt \
  mkpart ESP fat32 1Mib 512MiB \
  set 1 esp on \
  mkpart primary 512MiB 100%

# Format the partitions
mkfs.ext4 $ROOT
mkfs.vfat -F32 $EFI
mount $ROOT /mnt
mount --mkdir $EFI /mnt/boot

# Install base system
pacstrap -K /mnt linux-lts linux-lts-headers base base-devel vim terminus-font efibootmgr openssh dosfstools go git

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
echo "FONT=ter-d20b" >> /etc/vconsole.conf

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
mkinitcpio -P

# systemd-boot
bootctl install

# LUKS UUID
UUID=\$(blkid -o value -s UUID /dev/vda2)

# systemd-boot loader config
cat > /boot/loader/loader.conf <<LOADER
default arch
timeout 5
console-mode max
LOADER

cat > /boot/loader/entries/arch.conf <<ENTRY
title Arch Linux
linux /vmlinuz-linux-lts
initrd /initramfs-linux-lts.img
options root=UUID=\${UUID} rw
ENTRY

# Network services
cat > /etc/systemd/network/en.network <<NETWORK
[Match]
Name=en*
[Network]
DHCP=ipv4
NETWORK

# Start the services
systemctl enable systemd-networkd
systemctl enable systemd-resolved
systemctl enable systemd-timesyncd
systemctl enable sshd

# Hosts file
cat > /etc/hosts <<HOSTS
127.0.0.1    localhost
::1          localhost
127.0.1.1    $hostname.localdomain    $hostname
HOSTS

echo "Installation and basic configuration complete. Reboot"
EOF
