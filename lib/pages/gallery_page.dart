import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../constants/gallery_categories.dart';
import '../main.dart'; // برای دسترسی به Footer

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  String _selectedCategory = 'fitting';
  Map<String, List<String>> _categorizedImages = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGalleryImages();
  }

  /// بارگذاری تصاویر از AssetManifest.json
  Future<void> _loadGalleryImages() async {
    try {
      final manifestJson = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifest = json.decode(manifestJson);

      // گروه‌بندی تصاویر بر اساس پوشه
      Map<String, List<String>> categorized = {};

      for (String categoryKey in GalleryCategories.getCategoryKeys()) {
        final prefix = 'assets/img/gallery/$categoryKey/';
        final images = manifest.keys
            .where(
              (p) =>
                  p.startsWith(prefix) &&
                  (p.endsWith('.png') ||
                      p.endsWith('.jpg') ||
                      p.endsWith('.jpeg') ||
                      p.endsWith('.webp')),
            )
            .toList();

        if (images.isNotEmpty) {
          categorized[categoryKey] = images;
        }
      }

      setState(() {
        _categorizedImages = categorized;
        _isLoading = false;

        // انتخاب اولین دسته موجود
        if (categorized.isNotEmpty) {
          _selectedCategory = categorized.keys.first;
        }
      });
    } catch (e) {
      debugPrint('Failed to read AssetManifest: $e');
      setState(() {
        _categorizedImages = {};
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'گالری محصولات',
          style: TextStyle(
            fontFamily: 'Vazirmatn',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[800],
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'به‌روزرسانی',
            onPressed: () async {
              setState(() => _isLoading = true);
              await _loadGalleryImages();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categorizedImages.isEmpty
          ? const _EmptyState()
          : Column(
              children: [
                // نوار دسته‌بندی
                _buildCategoryTabs(),
                // خط جداکننده
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: Colors.grey[300],
                ),
                // گرید تصاویر
                Expanded(child: _buildImageGrid()),
              ],
            ),
      bottomNavigationBar: const Footer(), // اضافه کردن Footer مانند سایر صفحات
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categorizedImages.keys.length,
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final categoryKey = _categorizedImages.keys.elementAt(index);
          final isSelected = categoryKey == _selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = categoryKey;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue[800] : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.blue[800]! : Colors.grey[300]!,
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.blue[800]!.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      GalleryCategories.getCategoryIcon(categoryKey),
                      size: 18,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      GalleryCategories.getCategoryDisplayName(categoryKey),
                      style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageGrid() {
    final images = _categorizedImages[_selectedCategory] ?? [];

    if (images.isEmpty) {
      return const Center(
        child: Text(
          'هیچ تصویری در این دسته یافت نشد',
          style: TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return _buildImageCard(images[index], index);
        },
      ),
    );
  }

  Widget _buildImageCard(String imagePath, int index) {
    return GestureDetector(
      onTap: () => _showImageDialog(context, imagePath),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 150,
                color: Colors.grey[300],
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.grey, size: 40),
                    SizedBox(height: 8),
                    Text(
                      'خطا در بارگذاری تصویر',
                      style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 5,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[800],
                      padding: const EdgeInsets.all(16),
                      child: const Center(
                        child: Text(
                          'خطا در بارگذاری تصویر',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'هیچ تصویری یافت نشد',
        style: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 18,
          color: Colors.grey,
        ),
      ),
    );
  }
}
