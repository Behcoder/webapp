import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  List<String> _imagePaths = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGalleryImages();
  }

  /// همهٔ تصاویر داخل assets/img/gallery/ را از AssetManifest.json می‌خواند
  Future<void> _loadGalleryImages() async {
    try {
      final manifestJson = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifest = json.decode(manifestJson);

      const prefix = 'assets/img/gallery/';
      final images = manifest.keys
          .where((p) =>
              p.startsWith(prefix) &&
              (p.endsWith('.png') ||
               p.endsWith('.jpg') ||
               p.endsWith('.jpeg') ||
               p.endsWith('.webp')))
          .toList()
        ..sort();

      setState(() {
        _imagePaths = images;
        _isLoading = false;
      });

      // برای دیباگ: ببین چه چیزهایی پیدا شده
      // debugPrint('FOUND: ${images.length} -> $images');
    } catch (e) {
      debugPrint('Failed to read AssetManifest: $e');
      setState(() {
        _imagePaths = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _imagePaths.isEmpty
            ? const _EmptyState()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _imagePaths.length,
                  itemBuilder: (context, index) {
                    final imagePath = _imagePaths[index];
                    return GestureDetector(
                      onTap: () => _showImageDialog(context, imagePath),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
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
                            gaplessPlayback: true,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('Error loading: $imagePath -> $error');
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('گالری تصاویر'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
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
      body: body,
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
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
