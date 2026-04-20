#!/usr/bin/env bash
set -e

# مكان العمل
WORKDIR="$HOME/windows-idx"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# أسماء الملفات
ISO_URL="https://archive.org/download/20348.169.210806-1117.-fe-release-svc-prod-1-server-x-64-fre-en-us/20348.169.210806-1117.FE_RELEASE_SVC_PROD1_SERVER_X64FRE_EN-US.ISO"
ISO_FILE="win10.iso"
DISK_FILE="win10.qcow2"
LINKS_FILE="links.txt"

# 1. تنظيف القديم
pkill -f "ssh" || true
pkill -f "qemu" || true
rm -f tunnels.log "$LINKS_FILE"

# 2. إنشاء القرص والتحميل (لو مش موجودين)
if [ ! -f "$DISK_FILE" ]; then qemu-img create -f qcow2 "$DISK_FILE" 64G; fi
if [ ! -f "$ISO_FILE" ]; then wget -O "$ISO_FILE" "$ISO_URL"; fi

echo "🚀 جاري فتح الأنفاق وتسجيلها في الملف..."

# 3. فتح النفق (Serveo)

# انتظر لحظة عشان اللينك يتولد
sleep 15

# 4. استخراج الروابط وحفظها في ملف links.txt
echo "--- روابط الويندوز الخاصة بك ---" > "$LINKS_FILE"
echo "تاريخ التشغيل: $(date)" >> "$LINKS_FILE"
grep -oE 'forwarding from [a-zA-Z0-9.-]+' tunnels.log | sed 's/forwarding from /🔗 /' >> "$LINKS_FILE"
echo "------------------------------" >> "$LINKS_FILE"

echo "✅ تم حفظ الروابط في ملف: $LINKS_FILE"
cat "$LINKS_FILE"

# 5. تشغيل الويندوز (16GB RAM / 7 Cores)
echo "🎮 جاري تشغيل المثبت (Installation Mode)..."
qemu-system-x86_64 \
    -enable-kvm \
    -cpu host -smp 7 -m 16G -machine q35 \
    -drive file="$DISK_FILE",if=ide,format=qcow2 \
    -cdrom "$ISO_FILE" \
    -boot order=d \
    -vnc :0 \
    -net user,hostfwd=tcp::3389-:3389 -net nic \
    -usb -device usb-tablet
