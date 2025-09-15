import 'package:flutter/material.dart';

class GalleryCategories {
  static const Map<String, Map<String, dynamic>> _categories = {
    'fitting': {'displayName': 'فیتینگ', 'icon': Icons.build},
    'galvanized': {'displayName': 'گالوانیزه', 'icon': Icons.construction},
    'gas': {'displayName': 'گاز', 'icon': Icons.local_fire_department},
    'mannesmann': {
      'displayName': 'مانسمان',
      'icon': Icons.precision_manufacturing,
    },
    'scaffold': {'displayName': 'داربست', 'icon': Icons.view_in_ar},
    'spiral': {'displayName': 'مارپیچ', 'icon': Icons.timeline},
  };

  static List<String> getCategoryKeys() {
    return _categories.keys.toList();
  }

  static String getCategoryDisplayName(String categoryKey) {
    return _categories[categoryKey]?['displayName'] ?? categoryKey;
  }

  static IconData getCategoryIcon(String categoryKey) {
    return _categories[categoryKey]?['icon'] ?? Icons.category;
  }
}
