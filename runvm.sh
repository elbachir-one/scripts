#!/bin/sh

set -xe

QCOW2_IMAGE="$1"     # first argument: disk image (e.g. disk.qcow2)
ISO_IMAGE="$2"       # second argument: installer ISO
SSH_PORT="$3"        # third argument: port to forward host -> guest ssh

# Adjust this path to your system
UEFI_FIRMWARE="/usr/share/OVMF/x64/OVMF_CODE.fd"

qemu-system-x86_64 \
  -enable-kvm \
  -machine q35 \
  -cpu host \
  -smp cores=2 \
  -m 2048 \
  -bios "$UEFI_FIRMWARE" \
  \
  # attach qcow2 disk
  -drive file="$QCOW2_IMAGE",format=qcow2,if=virtio \
  \
  # attach ISO as CD-ROM
  -cdrom "$ISO_IMAGE" \
  \
  # boot from CD-ROM first, then disk
  -boot order=d \
  \
  # user-mode networking with SSH port forwarding
  -nic user,model=virtio,hostfwd=tcp::"$SSH_PORT"-:22 \
  \
  -nographic
