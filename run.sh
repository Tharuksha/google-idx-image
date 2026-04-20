#!/usr/bin/env bash
set -e

# Working directory
WORKDIR="$HOME/windows-idx"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# File names
ISO_URL="https://archive.org/download/20348.169.210806-1117.-fe-release-svc-prod-1-server-x-64-fre-en-us/20348.169.210806-1117.FE_RELEASE_SVC_PROD1_SERVER_X64FRE_EN-US.ISO"
ISO_FILE="win10.iso"
DISK_FILE="win10.qcow2"
LINKS_FILE="links.txt"

# 1. Clean up old state
pkill -f "ssh" || true
pkill -f "qemu" || true
rm -f tunnels.log "$LINKS_FILE"

# 2. Create disk and download ISO if missing
if [ ! -f "$DISK_FILE" ]; then qemu-img create -f qcow2 "$DISK_FILE" 64G; fi
if [ ! -f "$ISO_FILE" ]; then wget -O "$ISO_FILE" "$ISO_URL"; fi

echo "🚀 Opening tunnels and logging them to file..."

# 3. Open tunnel (Serveo)

# Wait a moment for the link to be generated
sleep 15

# 4. Extract links and save to links.txt
echo "--- Your Windows links ---" > "$LINKS_FILE"
echo "Started at: $(date)" >> "$LINKS_FILE"
grep -oE 'forwarding from [a-zA-Z0-9.-]+' tunnels.log | sed 's/forwarding from /🔗 /' >> "$LINKS_FILE"
echo "------------------------------" >> "$LINKS_FILE"

echo "✅ Links saved to file: $LINKS_FILE"
cat "$LINKS_FILE"

# 5. Run Windows (16GB RAM / 7 Cores)
echo "🎮 Starting installer (Installation Mode)..."
qemu-system-x86_64 \
    -enable-kvm \
    -cpu host -smp 7 -m 16G -machine q35 \
    -drive file="$DISK_FILE",if=ide,format=qcow2 \
    -cdrom "$ISO_FILE" \
    -boot order=d \
    -vnc :0 \
    -net user,hostfwd=tcp::3389-:3389 -net nic \
    -usb -device usb-tablet
