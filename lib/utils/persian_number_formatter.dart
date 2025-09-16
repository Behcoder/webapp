import 'package:intl/intl.dart';

class PersianNumberFormatter {
  static const Map<String, String> _englishToPersian = {
    '0': '۰',
    '1': '۱',
    '2': '۲',
    '3': '۳',
    '4': '۴',
    '5': '۵',
    '6': '۶',
    '7': '۷',
    '8': '۸',
    '9': '۹',
  };

  /// تبدیل اعداد انگلیسی به فارسی در یک رشته
  static String convertToPersian(String input) {
    String result = input;
    _englishToPersian.forEach((english, persian) {
      result = result.replaceAll(english, persian);
    });
    return result;
  }

  /// تبدیل عدد به فارسی
  static String convertNumberToPersian(num number) {
    return convertToPersian(number.toString());
  }

  /// تبدیل عدد صحیح به فارسی
  static String convertIntToPersian(int number) {
    return convertToPersian(number.toString());
  }

  /// تبدیل عدد اعشاری به فارسی
  static String convertDoubleToPersian(double number) {
    return convertToPersian(number.toString());
  }

  /// فرمت کردن قیمت با اعداد فارسی
  static String formatPersianPrice(double price) {
    final formatter = NumberFormat('#,###');
    final formattedPrice = formatter.format(price.round());
    return convertToPersian(formattedPrice);
  }

  /// فرمت کردن قیمت با واحد ریال
  static String formatPersianPriceWithUnit(double price) {
    return '${formatPersianPrice(price)} ریال';
  }

  /// فرمت کردن قیمت رشته‌ای با اعداد فارسی
  static String formatStringPersianPriceWithUnit(String priceString) {
    final price = double.tryParse(priceString) ?? 0.0;
    return formatPersianPriceWithUnit(price);
  }
}
