import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:convert';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> with TickerProviderStateMixin {
  TabController? _tabController;
  Map<String, List<String>> galleryImages = {};

  @override
  void initState() {
    super.initState();
    _loadGalleryImages();
  }

  Future<void> _loadGalleryImages() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      final generalImages = manifestMap.keys
          .where((String key) => key.startsWith('assets/img/gallery/general/'))
          .where((String key) => key.endsWith('.jpg') || key.endsWith('.png') || key.endsWith('.jpeg'))
          .toList();
      final productImages = manifestMap.keys
          .where((String key) => key.startsWith('assets/img/gallery/products/'))
          .where((String key) => key.endsWith('.jpg') || key.endsWith('.png') || key.endsWith('.jpeg'))
          .toList();
      setState(() {
        galleryImages = {
          'محصولات': productImages,
          'عمومی': generalImages,
        };
        _tabController?.dispose();
        _tabController = TabController(length: galleryImages.keys.length, vsync: this);
      });
    } catch (e) {
      print('Error loading gallery images: $e');
      setState(() {
        galleryImages = {
          'محصولات': [
            'assets/img/gallery/products/DSC_1052.jpg',
            'assets/img/gallery/products/DSC_1054.jpg',
            'assets/img/gallery/products/DSC_1068.jpg',
          ],
          'عمومی': [
            'assets/img/gallery/general/DSC_1037.jpg',
            'assets/img/gallery/general/DSC_1040.jpg',
            'assets/img/gallery/general/DSC_1043.jpg',
            'assets/img/gallery/general/DSC_1046.jpg',
          ],
        };
        _tabController?.dispose();
        _tabController = TabController(length: galleryImages.keys.length, vsync: this);
      });
    }
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
        bottom: _tabController != null && galleryImages.isNotEmpty
            ? TabBar(
                controller: _tabController,
                tabs: galleryImages.keys.map((cat) => Tab(text: cat)).toList(),
              )
            : null,
      ),
      body: _tabController != null && galleryImages.isNotEmpty
          ? TabBarView(
              controller: _tabController,
              children: galleryImages.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: entry.value.isEmpty
                      ? const Center(
                          child: Text('هیچ تصویری یافت نشد', style: TextStyle(fontSize: 16)),
                        )
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1,
                          ),
                          itemCount: entry.value.length,
                          itemBuilder: (context, index) {
                            final imagePath = entry.value[index];
                            return GestureDetector(
                              onTap: () => _showFullScreenImage(context, imagePath),
                              child: Hero(
                                tag: imagePath,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    imagePath,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                );
              }).toList(),
            )
          : const Center(child: CircularProgressIndicator()),
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
            child: InteractiveViewer(
              child: Image.asset(imagePath),
            ),
          ),
        ),
      ),
    );
  }
} 