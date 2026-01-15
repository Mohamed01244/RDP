#!/bin/bash
# إعدادات الهوية للحفظ
git config --global user.email "auto@bot.com"
git config --global user.name "Auto Bot"
git config --global credential.helper store

echo "🤖 روبوت الحفظ يعمل الآن في الخلفية (كل دقيقة)..."

while true; do
    # إضافة كل الملفات
    git add . >/dev/null 2>&1
    
    # هل يوجد تغيير؟ احفظه وارفع
    if ! git diff-index --quiet HEAD; then
        TIMESTAMP=$(date "+%H:%M")
        git commit -m "Auto-save $TIMESTAMP" >/dev/null 2>&1
        git push origin main >/dev/null 2>&1
        echo "✅ تم الحفظ التلقائي ($TIMESTAMP)"
    fi
    
    # انتظر 60 ثانية قبل الفحص التالي
    sleep 60
done
