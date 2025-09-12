import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  Map<String, List<String>> galleryImages = {};
  String selectedCategory = 'عمومی';
  bool isLoading = true;

  // دسته‌بندی‌ها به ترتیب الفبا (عمومی همیشه اول)
  final List<String> categories = [
    'عمومی',
    'API',
    'اسپیرال',
    'گازی',
    'گالوانیزه',
    'داربستی',
    'مانیسمان',
  ];

  @override
  void initState() {
    super.initState();
    _loadGalleryImages();
  }

  Future<void> _loadGalleryImages() async {
    // تعریف مسیرهای پوشه‌ها
    final Map<String, String> categoryPaths = {
      'عمومی': 'assets/img/gallery/general',
      'API': 'assets/img/gallery/API',
      'اسپیرال': 'assets/img/gallery/spiral',
      'گازی': 'assets/img/gallery/gas',
      'گالوانیزه': 'assets/img/gallery/galvanized',
      'داربستی': 'assets/img/gallery/scaffold',
      'مانیسمان': 'assets/img/gallery/manismann',
    };

    // تعریف فایل‌های موجود در هر پوشه
    final Map<String, List<String>> categoryFiles = {
      'عمومی': [
        '1.webp',
        '2.webp',
        '1001.png',
        '1002.png',
        '1101.jpg',
        '1102.jpg',
      ],
      'API': ['DSC_1052.jpg'],
      'اسپیرال': ['DSC_1046.jpg'],
      'گازی': ['DSC_1037.jpg'],
      'گالوانیزه': ['DSC_1043.jpg'],
      'داربستی': [],
      'مانیسمان': ['DSC_1040.jpg'],
    };

    // ساخت مسیرهای کامل
    setState(() {
      galleryImages = {};
      categoryPaths.forEach((category, path) {
        final files = categoryFiles[category] ?? [];
        galleryImages[category] = files.map((file) => '$path/$file').toList();
      });
      isLoading = false;
    });

    debugPrint('Gallery images loaded successfully!');
    galleryImages.forEach((category, images) {
      debugPrint('$category: ${images.length} images');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('گالری تصاویر'), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // دسته‌بندی‌های افقی
                _buildCategorySelector(),
                const SizedBox(height: 16),
                // Masonry Layout برای تصاویر
                Expanded(child: _buildMasonryGrid()),
              ],
            ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = category;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMasonryGrid() {
    final images = galleryImages[selectedCategory] ?? [];

    if (images.isEmpty) {
      return const Center(
        child: Text(
          'هیچ تصویری در این دسته یافت نشد',
          style: TextStyle(fontSize: 16, color: Colors.grey),
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
          final imagePath = images[index];
          return GestureDetector(
            onTap: () => _showFullScreenImage(context, imagePath),
            child: Hero(
              tag: imagePath,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildImageWidget(imagePath),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageWidget(String imagePath) {
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error loading image: $imagePath, Error: $error');
        return Container(
          color: Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.broken_image, size: 40, color: Colors.grey),
              const SizedBox(height: 8),
              Text(
                'خطا در بارگذاری',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFullScreenImage(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: Hero(
            tag: imagePath,
            child: InteractiveViewer(child: _buildImageWidget(imagePath)),
          ),
        ),
      ),
    );
  }
}
