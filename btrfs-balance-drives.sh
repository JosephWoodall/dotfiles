#!/usr/bin/env bash
set -euo pipefail

ROOT="/"

echo "=== Btrfs Auto-Expand Script ==="

# Get current root device
ROOT_DEV=$(findmnt -n -o SOURCE "$ROOT")
[[ $(lsblk -no FSTYPE "$ROOT_DEV") == "btrfs" ]] || { echo "Error: Root is not btrfs"; exit 1; }

# Find all unused disks (no filesystem, no mountpoint, type=disk)
CANDIDATES=()
while read -r dev fstype mount type; do
    [[ "$type" == "disk" && -z "$fstype" && -z "$mount" ]] && CANDIDATES+=("/dev/$dev")
done < <(lsblk -r -d -o NAME,FSTYPE,MOUNTPOINTS,TYPE --noheadings)

if [[ ${#CANDIDATES[@]} -eq 0 ]]; then
    echo "No new blank drives detected."
    echo "Current size:"
    df -h "$ROOT"
    exit 0
fi

echo "Found ${#CANDIDATES[@]} new drive(s): ${CANDIDATES[*]}"
echo "This will add them to the root btrfs pool (RAID0 data + RAID1 metadata)."
read -p "Continue? (y/N): " -n1 confirm
echo

[[ "$confirm" =~ ^[Yy]$ ]] || { echo "Cancelled."; exit 1; }

# Add new drives
echo "Adding drives..."
btrfs device add "${CANDIDATES[@]}" "$ROOT"

# Resize to use full space
echo "Resizing filesystem..."
btrfs filesystem resize max "$ROOT"

# Rebalance (converts new data to RAID0, keeps metadata RAID1)
echo "Starting balance (this may take a long time)..."
btrfs balance start -dconvert=raid0 -mconvert=raid1 "$ROOT"

echo "Waiting for balance to finish..."
while btrfs balance status "$ROOT" | grep -q "running"; do
    sleep 30
done

echo "=== Done! ==="
df -h "$ROOT"
btrfs filesystem show "$ROOT" | head -n 5
