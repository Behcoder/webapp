# راهنمای استقرار وب اپ سیفی مارکت روی هاست

## 📋 اطلاعات کلی
- **نام پروژه**: سیفی مارکت (Seify Market)
- **نوع**: Progressive Web App (PWA)
- **تاریخ بیلد**: 2025/09/16 10:54
- **حجم فایل زیپ**: 19.50 مگابایت
- **حجم کل فایل‌های وب**: 39.84 مگابایت

## 🔗 لینک‌های مهم
- **API Backend**: https://seify.ir/wp-json/wc/v3/
- **فایل تنظیمات**: assets/config.env

## 📁 محتویات بسته وب

### فایل‌های اصلی:
- `index.html` - صفحه اصلی وب اپ
- `main.dart.js` - کد اصلی Flutter (3.1 MB)
- `flutter_service_worker.js` - Service Worker برای PWA
- `manifest.json` - تنظیمات PWA
- `favicon.png` - آیکون سایت

### پوشه‌ها:
- `assets/` - تصاویر، فونت‌ها و منابع
- `icons/` - آیکون‌های مختلف برای PWA
- `canvaskit/` - فایل‌های CanvasKit برای رندرینگ

### فایل‌های پیکربندی سرور:
- `.htaccess` - تنظیمات Apache
- `web.config` - تنظیمات IIS

## 🚀 مراحل استقرار روی هاست

### مرحله ۱: آماده‌سازی هاست
1. ✅ **دامنه/ساب‌دامنه آماده باشد**
2. ✅ **پنل مدیریت هاست (cPanel/DirectAdmin/etc.)**
3. ✅ **دسترسی به File Manager یا FTP**

### مرحله ۲: آپلود فایل‌ها
1. **استخراج فایل زیپ**: محتویات `Seify_Market_WebApp_xxxxxxx.zip` را استخراج کنید
2. **آپلود به public_html**: تمام فایل‌ها را در پوشه public_html (یا www) آپلود کنید
3. **حفظ ساختار پوشه‌ها**: مطمئن شوید ساختار پوشه‌ها حفظ شود

### مرحله ۳: تنظیمات سرور

#### برای Apache (با .htaccess):
فایل `.htaccess` در بسته موجود است و شامل تنظیمات زیر:
```apache
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteRule ^.*$ /index.html [L]

# Enable compression
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/plain text/html text/xml text/css text/js application/javascript
</IfModule>

# Cache settings
<IfModule mod_expires.c>
    ExpiresActive on
    ExpiresByType text/css "access plus 1 year"
    ExpiresByType application/javascript "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
</IfModule>
```

#### برای IIS:
فایل `web.config` در بسته موجود است.

### مرحله ۴: تست و بررسی
1. **باز کردن سایت**: https://yourdomain.com
2. **بررسی عملکرد**:
   - ✅ بارگذاری صفحه اصلی
   - ✅ نمایش محصولات
   - ✅ عملکرد جستجو
   - ✅ دسته‌بندی‌ها
   - ✅ گالری تصاویر

## 🔧 تنظیمات بهینه‌سازی

### برای بهبود سرعت:
1. **فعال‌سازی Gzip compression** (معمولاً روی اکثر هاست‌ها فعال است)
2. **تنظیم Cache headers** (در .htaccess موجود است)
3. **استفاده از CDN** (اختیاری)

### برای امنیت:
1. **SSL Certificate** - حتماً HTTPS فعال کنید
2. **محافظت از فایل‌های حساس** (در .htaccess تنظیم شده)

## 🌐 ویژگی‌های PWA

وب اپ شامل قابلیت‌های PWA:
- ✅ **Install prompt** - کاربران می‌توانند روی دستگاه نصب کنند
- ✅ **Offline support** - برخی قسمت‌ها offline کار می‌کنند
- ✅ **Responsive design** - روی تمام دستگاه‌ها کار می‌کند
- ✅ **Fast loading** - Service Worker برای بهبود سرعت

## 📱 سازگاری

### مرورگرهای پشتیبانی شده:
- ✅ Chrome 88+
- ✅ Firefox 78+
- ✅ Safari 14+
- ✅ Edge 88+

### دستگاه‌ها:
- ✅ Desktop (Windows, Mac, Linux)
- ✅ Mobile (Android, iOS)
- ✅ Tablet

## 🚨 نکات مهم

### ⚠️ مسائل احتمالی:
1. **Mixed Content**: اگر سایت روی HTTPS است، همه منابع باید HTTPS باشند
2. **CORS Issues**: API ها باید CORS مناسب داشته باشند
3. **File Permissions**: فایل‌ها باید دسترسی خواندن داشته باشند (644)

### 🔍 عیب‌یابی:
1. **Console Browser**: F12 → Console برای بررسی خطاها
2. **Network Tab**: بررسی درخواست‌های API
3. **Application Tab**: بررسی Service Worker و Cache

## 📞 پشتیبانی

در صورت بروز مشکل:
1. بررسی console مرورگر
2. چک کردن تنظیمات هاست
3. تست روی مرورگرهای مختلف

---
**✅ آماده برای استقرار**: فایل `Seify_Market_WebApp_20250916_105413.zip`  
**📍 مسیر**: `d:\beb_app-dev\beb_app-dev-Y04M06D24\Seify_Market_WebApp_20250916_105413.zip`  
**🎯 وضعیت**: Production Ready