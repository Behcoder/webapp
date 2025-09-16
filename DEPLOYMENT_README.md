# راهنمای استقرار اپلیکیشن سیفی مارکت

## اطلاعات پروژه
- **نام**: سیفی مارکت (Seify Market)
- **نوع**: اپلیکیشن فروشگاهی Flutter
- **تاریخ آماده‌سازی**: 2025/09/16 10:35:00
- **ورژن Flutter**: 3.35.2
- **پلتفرم‌های پشتیبانی شده**: Android, iOS, Windows, Web

## محتویات بسته

### فولدرهای اصلی:
- `lib/` - کد منبع اصلی اپلیکیشن
- `assets/` - تصاویر، فونت‌ها و منابع
- `android/` - تنظیمات مخصوص Android
- `ios/` - تنظیمات مخصوص iOS
- `web/` - تنظیمات مخصوص Web
- `windows/` - تنظیمات مخصوص Windows

### فایل‌های مهم:
- `pubspec.yaml` - وابستگی‌ها و تنظیمات پروژه
- `pubspec.lock` - نسخه‌های دقیق وابستگی‌ها
- `ERROR_HANDLING_GUIDE.md` - راهنمای سیستم مدیریت خطا
- `RELEASE_CHECKLIST.txt` - چک‌لیست انتشار

## ویژگی‌های پیاده‌سازی شده

### ✅ تکمیل شده:
1. **تصاویر ریسپانسیو** - BoxFit.cover برای نمایش بهتر
2. **جستجو** - صفحه جستجوی کامل با API WooCommerce
3. **فرمت قیمت** - جداکننده هزارگان با اعداد فارسی
4. **فوتر گالری** - اضافه شدن فوتر به صفحه گالری
5. **نویگیشن زیردسته‌ها** - رفع مشکل کلیک در صفحه دسته‌بندی
6. **اعداد فارسی** - تبدیل تمام اعداد انگلیسی به فارسی
7. **مدیریت خطا** - سیستم کامل مدیریت خطا برای production

### 🔧 سیستم مدیریت خطا:
- **GlobalErrorHandler** - مدیریت خطاهای سراسری
- **ErrorBoundary** - محافظت صفحات خاص
- **ProductionErrorWidget** - نمایش خطاهای کاربرپسند

## دستورالعمل استقرار

### 1. پیش‌نیازها:
```bash
flutter --version  # باید 3.35.2 یا بالاتر باشد
dart --version
```

### 2. نصب وابستگی‌ها:
```bash
flutter pub get
```

### 3. بیلد برای Android:
```bash
flutter build apk --release
# یا برای App Bundle:
flutter build appbundle --release
```

### 4. بیلد برای iOS:
```bash
flutter build ios --release
```

### 5. بیلد برای Web:
```bash
flutter build web --release
```

### 6. بیلد برای Windows:
```bash
flutter build windows --release
```

## تنظیمات API

### WooCommerce API:
- **Base URL**: https://seify.ir/wp-json/wc/v3/
- **Consumer Key**: ck_278d4ac63be04448206d8aec329301bd58831670
- **Consumer Secret**: cs_c4d143188011db4cce3137dd7c046c435f18114b

### فایل تنظیمات:
```
assets/config.env
```

## نکات مهم

### 🚨 هشدارها:
1. **هرگز از Hot Reload استفاده نکنید** - همیشه restart کامل انجام دهید
2. کلیدهای API در فایل config.env قرار دارند
3. تصاویر و بنرها در پوشه assets ذخیره شده‌اند

### 📱 پلتفرم‌ها:
- **Android**: API level 21+ (Android 5.0+)
- **iOS**: iOS 12.0+
- **Web**: Modern browsers
- **Windows**: Windows 10+

### 🔍 عیب‌یابی:
1. در صورت خطا در build، ابتدا `flutter clean` اجرا کنید
2. بررسی کنید که تمام وابستگی‌ها نصب شده باشند
3. برای مشکلات API، اتصال اینترنت را چک کنید

## پشتیبانی

در صورت بروز مشکل:
1. چک کردن فایل `ERROR_HANDLING_GUIDE.md`
2. بررسی لاگ‌های console
3. استفاده از `flutter doctor` برای بررسی محیط توسعه

---
**تاریخ آماده‌سازی**: 2025/09/16 10:35:00  
**وضعیت**: آماده برای production  
**مدیریت خطا**: پیاده‌سازی شده ✅