#!/bin/bash

# Void Linux Setup Script
# Author: [Your Name]
# Purpose: Automate the setup process for Void Linux with optional desktop environments or window managers.

# Check if script is running as root
if [ "$EUID" -ne 0 ]; then
	echo "Please run this script as root."
	exit 1
fi

# Define functions
add_repositories() {
	echo "Adding non-free and multilib repositories..."
	echo "repository=https://repo.voidlinux.org/current/nonfree" >> /etc/xbps.d/10-repository-configuration.conf
	echo "repository=https://repo.voidlinux.org/current/multilib" >> /etc/xbps.d/10-repository-configuration.conf
	xbps-install -Suy xbps
}

install_base_packages() {
	echo "Installing base packages..."
	xbps-install -Sy base-devel xorg noto-fonts-ttf noto-fonts-emoji \
		noto-fonts-jck curl wget git neovim htop alsa-utils neofetch
	}

setup_desktop_environment() {
	echo "Choose a desktop environment:
	1) KDE
	2) GNOME
	3) Skip"
	read -rp "Enter your choice: " choice

	case $choice in
		1)
			echo "Installing KDE Plasma..."
			xbps-install -Sy kde5 kde5-baseapps sddm
			ln -s /etc/sv/sddm /var/service/
			;;
		2)
			echo "Installing GNOME..."
			xbps-install -Sy gnome gdm
			ln -s /etc/sv/gdm /var/service/
			;;
		3)
			echo "Skipping desktop environment setup."
			;;
		*)
			echo "Invalid choice. Skipping."
			;;
	esac
}

setup_hyprland() {
	echo "Setting up Hyprland..."
	echo "repository=https://raw.githubusercontent.com/Makrennel/hyprland-void/repository-x86_64-glibc" \
		> /etc/xbps.d/20-hyprland-repo.conf
				xbps-install -Sy hyprland
				xbps-install -Sy xdg-desktop-portal xdg-desktop-portal-hyprland
				ln -s /etc/sv/dbus /var/service/
				ln -s /etc/sv/polkitd /var/service/
			}

setup_dwm() {
	echo "Setting up DWM and related tools..."
	xbps-install -Sy libX11-devel libXft-devel libXinerama-devel

	mkdir -p ~/.config/suckless
	git clone https://git.suckless.org/dwm ~/.config/suckless/dwm
	git clone https://git.suckless.org/st ~/.config/suckless/st
	git clone https://git.suckless.org/dmenu ~/.config/suckless/dmenu

	(cd ~/.config/suckless/dwm && make clean install)
	(cd ~/.config/suckless/st && make clean install)
	(cd ~/.config/suckless/dmenu && make clean install)
}

setup_audio() {
	echo "Choose an audio system:
	1) PulseAudio
	2) PipeWire"
	read -rp "Enter your choice: " choice

	case $choice in
		1)
			echo "Setting up PulseAudio..."
			xbps-install -Sy pulseaudio pavucontrol
			ln -s /etc/sv/pulseaudio /var/service/
			;;
		2)
			echo "Setting up PipeWire..."
			xbps-install -Sy pipewire pipewire-alsa pipewire-pulse wireplumber
			ln -s /etc/sv/pipewire /var/service/
			ln -s /etc/sv/wireplumber /var/service/
			;;
		*)
			echo "Invalid choice. Skipping audio setup."
			;;
	esac
}

add_user() {
	read -rp "Enter a username to create: " username
	useradd -m -G wheel,video,audio "$username"
	passwd "$username"
	echo "User $username added and assigned to necessary groups."
}

# Main menu
echo "Void Linux Setup Script"
echo "1) Add Repositories"
echo "2) Install Base Packages"
echo "3) Setup Desktop Environment"
echo "4) Setup Hyprland"
echo "5) Setup DWM"
echo "6) Setup Audio"
echo "7) Add User"
echo "8) Exit"

while true; do
	read -rp "Enter your choice: " option

	case $option in
		1)
			add_repositories
			;;
		2)
			install_base_packages
			;;
		3)
			setup_desktop_environment
			;;
		4)
			setup_hyprland
			;;
		5)
			setup_dwm
			;;
		6)
			setup_audio
			;;
		7)
			add_user
			;;
		8)
			echo "Exiting."
			exit 0
			;;
		*)
			echo "Invalid choice. Please try again."
			;;
	esac

done
