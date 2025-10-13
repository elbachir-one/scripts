#!/usr/bin/env bash

# --- Arch Linux Encrypted Installation ---

set -euo pipefail

# Variables
lvmpassword="arch"
rootpassword="arch"
username="arch"
userpassword="arch"
hostname="ARCH"
device="/dev/vda"

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
mkfs.fat -F32 /dev/vda1

# Setup LUKS
echo "$lvmpassword" | cryptsetup --use-random luksFormat /dev/vda2
echo "$lvmpassword" | cryptsetup luksOpen /dev/vda2 cryptlvm

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
mount --mkdir /dev/vda1 /mnt/boot

# Install base system
pacstrap -K /mnt linux linux-firmware base base-devel vim nano terminus-font efibootmgr lvm2 cryptsetup networkmanager openssh os-prober dosfstools amd-ucode grub os-prober

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

# Grub

echo GRUB_ENABLE_CRYPTODISK=y >> /etc/default/grub

sed -i "s|^GRUB_CMDLINE_LINUX_DEFAULT=.*|GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet cryptdevice=UUID=$(blkid -o value -s UUID /dev/vda2):cryptlvm root=UUID=$(blkid -o value -s UUID /dev/vg0/root)\"|" /etc/default/grub

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck

grub-mkconfig -o /boot/grub/grub.cfg

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

mkinitcpio -P

echo "Installation and basic configuration complete. Reboot"
EOF
