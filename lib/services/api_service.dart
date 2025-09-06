import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static String get baseUrl =>
      dotenv.env['WOOCOMMERCE_BASE_URL'] ?? 'https://seify.ir/wp-json/wc/v3';
  static String get consumerKey => dotenv.env['WOOCOMMERCE_CONSUMER_KEY'] ?? '';
  static String get consumerSecret =>
      dotenv.env['WOOCOMMERCE_CONSUMER_SECRET'] ?? '';

  // Products API
  static String getProductsUrl(
      {int? page, int? categoryId, String? orderBy, String? order}) {
    String url =
        '$baseUrl/products?consumer_key=$consumerKey&consumer_secret=$consumerSecret';

    if (page != null) url += '&page=$page';
    if (categoryId != null) url += '&category=$categoryId';
    if (orderBy != null) url += '&orderby=$orderBy';
    if (order != null) url += '&order=$order';

    return url;
  }

  // Categories API
  static String getCategoriesUrl({int? parentId}) {
    String url =
        '$baseUrl/products/categories?consumer_key=$consumerKey&consumer_secret=$consumerSecret';

    if (parentId != null) url += '&parent=$parentId';

    return url;
  }

  // Product Reviews API
  static String getProductReviewsUrl(int productId) {
    return '$baseUrl/products/reviews?consumer_key=$consumerKey&consumer_secret=$consumerSecret&product=$productId';
  }

  // Submit Review API
  static String getSubmitReviewUrl() {
    return '$baseUrl/products/reviews?consumer_key=$consumerKey&consumer_secret=$consumerSecret';
  }
}
