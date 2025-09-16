# راهنمای حل مشکل کادر سفید دور آیکون اپ

## 🎯 مشکل
آیکون اپ سیفی مارکت در موبایل دارای کادر سفید است که ناخوشایند به نظر می‌رسد.

## 🔧 علت مشکل
مشکل از آیکون `launcher_icon` است که احتمالاً پس‌زمینه سفید دارد یا برای adaptive icon اندروید بهینه نشده است.

## ✅ راه‌حل‌های اعمال شده

### 1. تغییر آیکون در AndroidManifest.xml
```xml
<!-- قبل -->
android:icon="@mipmap/launcher_icon"

<!-- بعد -->
android:icon="@mipmap/ic_launcher"
```

### 2. ایجاد Adaptive Icon
فایل‌های زیر ایجاد شده‌اند:
- `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml`
- `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml`
- `android/app/src/main/res/drawable/ic_launcher_background.xml` (پس‌زمینه شفاف)
- `android/app/src/main/res/drawable/ic_launcher_foreground.xml` (آیکون فروشگاه)

### 3. مشخصات Adaptive Icon جدید
- **پس‌زمینه**: شفاف (بدون کادر سفید)
- **Foreground**: آیکون فروشگاه با رنگ آبی
- **سازگاری**: Android 8.0+ (API 26+)

## 📱 نتیجه
پس از نصب APK جدید:
- آیکون دیگر کادر سفید نخواهد داشت
- در launcher های مختلف به درستی نمایش داده می‌شود
- شکل آیکون با تم دستگاه سازگار است

## 🔄 مراحل آپدیت
1. ✅ فایل‌های آیکون تصحیح شده‌اند
2. ⏳ APK در حال build است
3. ⭕ نصب APK جدید روی دستگاه
4. ⭕ تست آیکون در launcher

## 📝 نکات مهم
- حتماً APK قدیمی را uninstall کنید
- APK جدید را نصب کنید
- ممکن است launcher cache کنید، restart کنید
- در برخی launcher ها ممکن است کمی طول بکشد تا آیکون آپدیت شود

## 🎨 سفارشی‌سازی بیشتر
اگر می‌خواهید آیکون خاص خودتان را اضافه کنید:
1. آیکون SVG یا PNG آماده کنید
2. از ابزار Android Studio Icon Generator استفاده کنید
3. فایل‌های مربوطه را جایگزین کنید

---
**وضعیت فعلی**: آیکون تصحیح شده و APK در حال build است ⚙️