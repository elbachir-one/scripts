#!/usr/bin/env bash

qemu-system-x86_64 \
    -enable-kvm \
    -machine q35 \
    -cpu host \
    -smp cores=1,threads=1,sockets=1 \
    -m 1024M \
    -drive if=pflash,format=raw,readonly=on,file=/usr/share/ovmf/x64/OVMF_CODE.4m.fd \
    -drive if=pflash,format=raw,file=/home/user1/vms/vm1/uefi_VARS.fd \
    -drive file=/devel/qemu-storage-pool/vm1.raw,format=raw,if=virtio,cache=none,aio=native \
    -cdrom "$HOME/Downloads/archlinux-2025.12.01-x86_64.iso" \
    -netdev bridge,id=net0,br=nm-bridge \
    -device virtio-net-pci,netdev=net0 \
    -device virtio-vga-gl \
    -display gtk,gl=on,grab-on-hover=on \
    -device usb-ehci,id=usb \
    -device usb-kbd,bus=usb.0 \
    -device usb-mouse,bus=usb.0
