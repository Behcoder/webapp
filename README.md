# سیفی مارکت - اپلیکیشن فروشگاه آنلاین

## 📱 درباره اپ
سیفی مارکت یکی از بزرگترین فروشگاه‌های آنلاین ایران در زمینه فروش لوله های فولادی، اتصالات، شیرآلات و انواع آهن آلات می‌باشد.

## 🔧 راه‌اندازی

### پیش‌نیازها
- Flutter SDK 3.2.3 یا بالاتر
- Dart SDK
- Android Studio / VS Code

### نصب و راه‌اندازی

1. **کلون کردن پروژه**
```bash
git clone [repository-url]
cd app_4502
```

2. **نصب پکیج‌ها**
```bash
flutter pub get
```

3. **تنظیم API Keys**
   
   فایل `assets/config.env` را ایجاد کنید:
   ```env
   WOOCOMMERCE_CONSUMER_KEY=your_consumer_key_here
   WOOCOMMERCE_CONSUMER_SECRET=your_consumer_secret_here
   WOOCOMMERCE_BASE_URL=https://your-domain.com/wp-json/wc/v3
   ```

4. **اجرای اپ**
```bash
flutter run
```

## 🔐 امنیت API Keys

### برای توسعه:
- از فایل `assets/config.env` استفاده کنید
- این فایل در `.gitignore` قرار دارد و در repository آپلود نمی‌شود

### برای انتشار:
- API Keys را در محیط production تغییر دهید
- از کلیدهای محدود شده استفاده کنید
- کلیدهای قدیمی را غیرفعال کنید

## 📦 ساخت APK

```bash
flutter build apk --release
```

## 🚀 انتشار

قبل از انتشار، موارد زیر را بررسی کنید:
- [ ] API Keys امن شده‌اند
- [ ] نام اپ در AndroidManifest اصلاح شده
- [ ] آیکون سفارشی اضافه شده
- [ ] مجوزهای لازم اضافه شده‌اند

## 📞 پشتیبانی

برای سوالات و مشکلات، با تیم توسعه تماس بگیرید.

## 📄 لایسنس

این پروژه تحت لایسنس [لایسنس شما] منتشر شده است.
