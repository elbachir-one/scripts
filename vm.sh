#!/usr/bin/env bash

# Run installed VM's using virsh

# Check if a VM name is provided
if [ -z "$1" ]; then
	echo "Usage: $0 <vm_name>"
	exit 1
fi

VM_NAME=$1

# Check if the VM is already running
if sudo virsh domstate "$VM_NAME" | grep -q "running"; then
	echo "Domain '$VM_NAME' is already running."
else
	sudo virsh start "$VM_NAME"

# Wait for 20 seconds to ensure the VM is up
sleep 20
fi

# SSH into the VM using the alias
bash -i -c "$VM_NAME"
