#!/bin/bash
# 1. تنظيف أي حاويات قديمة لتجنب أخطاء Port Conflict
docker rm -f fast-rdp || true

# 2. تشغيل حاوية الـ RDP مع تفعيل خاصية الحفظ التلقائي والسرعة القصوى
docker run -d \
  --name=fast-rdp \
  -p 3000:3000 \
  -v "$(pwd):/config" \
  -e TZ=Africa/Cairo \
  --shm-size="2gb" \
  --restart unless-stopped \
  ghcr.io/linuxserver/webtop:ubuntu-xfce

# 3. التأكد من صلاحيات تشغيل متصفح Dolphin
if [ -d "/workspaces/RDP/squashfs-root" ]; then
    chmod +x /workspaces/RDP/squashfs-root/dolphin_anty
fi

# 4. إعادة إنشاء اختصار سطح المكتب تلقائياً ليكون جاهزاً دائماً
mkdir -p ~/Desktop
echo "[Desktop Entry]
Version=1.0
Type=Application
Name=Dolphin Anty
Exec=/config/dolphin/dolphin_anty --no-sandbox
Icon=/config/dolphin/dolphin_anty.png
Terminal=false" > ~/Desktop/Dolphin.desktop
chmod +x ~/Desktop/Dolphin.desktop

