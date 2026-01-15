#!/bin/bash

# إنشاء مجلد لحفظ البيانات بجوار السكربت لضمان عدم ضياع الملفات
mkdir -p rdp_data

echo "🚀 [1/4] إعداد وتشغيل الـ RDP السريع..."

# تنظيف الحاويات القديمة (مع الحفاظ على مجلد البيانات)
sudo kill -9 $(sudo lsof -t -i:3005) 2>/dev/null || true
docker rm -f fast-rdp 2>/dev/null || true

# تشغيل الحاوية مع ربط مجلد البيانات rdp_data
# تم تحسين الذاكرة وتثبيت التوقيت
docker run -d \
  --name=fast-rdp \
  -p 3005:3000 \
  -v "$(pwd)/rdp_data:/config" \
  -e TZ=Africa/Cairo \
  --shm-size="2gb" \
  --restart unless-stopped \
  ghcr.io/linuxserver/webtop:ubuntu-xfce

echo "🧹 [2/4] تنظيف الملفات القديمة (أكثر من 5 أيام)..."
# هذا الأمر يحذف الملفات في التنزيلات والكاش التي مر عليها 5 أيام
docker exec -u root fast-rdp bash -c "
  find /config/Downloads -type f -mtime +5 -delete 2>/dev/null
  find /tmp -type f -mtime +5 -delete 2>/dev/null
  echo '✅ تم تنظيف الملفات القديمة.'
"

echo "⏳ [3/4] التحقق من Google Chrome..."
# التحقق مما إذا كان كروم مثبتاً لتسريع العملية وعدم تحميله مرة أخرى
docker exec -u root fast-rdp bash -c "
  if [ ! -f \"/usr/bin/google-chrome\" ]; then
    echo '⬇️ جاري تثبيت Chrome لأول مرة...'
    apt-get update -qq >/dev/null
    apt-get install -y -qq curl wget libnss3 libasound2t64 >/dev/null
    wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    apt-get install -y ./google-chrome-stable_current_amd64.deb >/dev/null
    rm google-chrome-stable_current_amd64.deb
  else
    echo '⚡ Chrome مثبت بالفعل، تجاوز التحميل.'
  fi
"

echo "🖥️ [4/4] تحديث أيقونات سطح المكتب..."
docker exec -u root fast-rdp bash -c "
  mkdir -p /config/Desktop
  
  # اختصار Chrome
  echo '[Desktop Entry]
  Version=1.0
  Type=Application
  Name=Google Chrome
  Exec=/usr/bin/google-chrome --no-sandbox
  Icon=google-chrome
  Terminal=false' > /config/Desktop/Chrome.desktop
  
  chmod +x /config/Desktop/*.desktop
  chown -R abc:abc /config/Desktop
"

echo "✅ تم التشغيل بنجاح!"
echo "🌍 الرابط: http://localhost:3005"