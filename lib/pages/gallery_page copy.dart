import 'package:flutter/material.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage>
    with TickerProviderStateMixin {
  TabController? _tabController;
  Map<String, List<String>> _imagesByCategory = {};
  bool _isLoading = true;

  // لیست ثابت تصاویر بر اساس فایل‌های موجود
  final Map<String, List<String>> _staticImages = {
    'Gallery': [
      'assets/img/gallery/1001.png',
      'assets/img/gallery/2.webp',
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  void _loadImages() {
    setState(() {
      _imagesByCategory = _staticImages;
      _tabController = TabController(
        length: _imagesByCategory.length,
        vsync: this,
      );
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('گالری تصاویر'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: _isLoading
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: _imagesByCategory.keys
                    .map((category) => Tab(text: category))
                    .toList(),
              ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _imagesByCategory.isEmpty
          ? const Center(
              child: Text(
                'هیچ تصویری یافت نشد',
                style: TextStyle(fontSize: 18),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: _imagesByCategory.keys
                  .map(
                    (category) => _buildImageGrid(_imagesByCategory[category]!),
                  )
                  .toList(),
            ),
    );
  }

  Widget _buildImageGrid(List<String> imagePaths) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          final imagePath = imagePaths[index];
          return GestureDetector(
            onTap: () => _showImageDialog(context, imagePath),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint(
                      'Error loading image: $imagePath, Error: $error',
                    );
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[800],
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
                  backgroundColor: Colors.black.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
