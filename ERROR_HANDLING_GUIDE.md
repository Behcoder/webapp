# سیستم مدیریت خطا در اپلیکیشن سیفی مارکت

## توضیحات

این سیستم برای اطمینان از عدم نمایش خطاهای قرمز debug به کاربران نهایی در محیط production طراحی شده است.

## اجزای سیستم

### 1. GlobalErrorHandler
فایل: `lib/widgets/error_handler.dart`

این کلاس مسئول مدیریت خطاهای سراسری در برنامه است:
- در حالت debug: خطاهای استاندارد فلاتر نمایش داده می‌شوند
- در حالت production: صفحه کاربرپسند با پیام "مشکلی پیش آمد. دوباره تلاش کنید" نمایش داده می‌شود

### 2. ErrorBoundary
فایل: `lib/widgets/error_boundary.dart`

این ویجت برای محافظت از بخش‌های خاص برنامه استفاده می‌شود:
- امکان wrap کردن هر ویجت
- نمایش صفحه خطای سفارشی
- قابلیت retry برای تلاش مجدد

### 3. ProductionErrorWidget
ویجت خاص برای نمایش خطا در حالت production:
- آیکون متناسب
- پیام فارسی
- دکمه بازگشت

## راه‌اندازی در main.dart

```dart
void main() async {
  // راه‌اندازی مدیریت خطاهای عمومی
  GlobalErrorHandler.setupErrorHandling();

  // تنظیم ErrorWidget builder برای production
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return GlobalErrorHandler.buildErrorWidget(details);
  };

  runApp(const MyApp());
}
```

## نحوه استفاده

### برای صفحات حساس:
```dart
class CriticalPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      child: Scaffold(
        // محتوای صفحه
      ),
    );
  }
}
```

### برای بخش‌های خاص:
```dart
ErrorBoundary(
  child: FutureBuilder(
    // API calls یا عملیات حساس
  ),
)
```

## مزایا

1. **تجربه کاربری بهتر**: کاربران هرگز خطاهای قرمز debug نمی‌بینند
2. **پیام‌های فارسی**: خطاها به زبان فارسی نمایش داده می‌شوند
3. **قابلیت بازیابی**: امکان retry و بازگشت به صفحه قبلی
4. **سازگاری**: در حالت debug همچنان خطاهای تفصیلی برای توسعه‌دهندگان نمایش داده می‌شوند

## نکات مهم

- این سیستم فقط در حالت production فعال است
- در حالت debug، خطاهای استاندارد فلاتر نمایش داده می‌شوند
- برای استفاده در صفحات API، حتماً از ErrorBoundary استفاده کنید
- همیشه import مسیر نسبی را صحیح تنظیم کنید

## مثال کامل

```dart
import 'package:flutter/material.dart';
import '../widgets/error_boundary.dart';

class ProductsPage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      child: Scaffold(
        appBar: AppBar(title: Text('محصولات')),
        body: FutureBuilder(
          future: fetchProducts(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              throw snapshot.error!;
            }
            // نمایش محصولات
            return ProductList();
          },
        ),
      ),
    );
  }
}
```

این سیستم باعث می‌شود که کاربران نهایی هرگز صفحات خطای قرمز نبینند و در عوض پیام مناسب دریافت کنند.