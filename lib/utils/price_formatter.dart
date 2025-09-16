import 'package:intl/intl.dart';
import 'persian_number_formatter.dart';

/// Utility class for formatting prices with Persian locale
class PriceFormatter {
  // جداکننده سه‌رقمی برای قیمت‌ها با استفاده از locale فارسی و اعداد فارسی
  static String formatPrice(double price) {
    final formatter = NumberFormat('#,###', 'fa_IR');
    final formattedPrice = formatter.format(price.round());
    // تبدیل اعداد انگلیسی به فارسی
    return PersianNumberFormatter.convertToPersian(formattedPrice);
  }

  // فرمت کامل با واحد ریال
  static String formatPriceWithUnit(double price) {
    return '${formatPrice(price)} ریال';
  }

  // فرمت برای قیمت‌های رشته‌ای
  static String formatStringPrice(String priceString) {
    final price = double.tryParse(priceString);
    if (price == null)
      return PersianNumberFormatter.convertToPersian(priceString);
    return formatPrice(price);
  }

  // فرمت کامل برای قیمت‌های رشته‌ای
  static String formatStringPriceWithUnit(String priceString) {
    final price = double.tryParse(priceString);
    if (price == null)
      return PersianNumberFormatter.convertToPersian(priceString);
    return formatPriceWithUnit(price);
  }
}
