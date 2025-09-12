import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});
  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage>
    with TickerProviderStateMixin {
  TabController? _tabController;
  // slug -> list of asset paths
  Map<String, List<String>> _imagesByCategory = {};
  // ترتیب و برچسب‌های فارسی
  static const Map<String, String> _faLabel = {
    'general': 'عمومی',
    'API': 'API',
    'galvanized': 'گالوانیزه',
    'gas': 'گازی',
    'spiral': 'اسپیرال',
    'scaffold': 'داربستی',
    'manismann': 'مانیسمان',
    'gal': 'گال' // اگر در پروژه‌تان استفاده می‌شود
  };
  static const List<String> _preferredOrder = [
    'general',
    'API',
    'galvanized',
    'gas',
    'spiral',
    'scaffold',
    'manismann',
    'gal'
  ];
  static const List<String> _allowedExt = [
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
    '.JPG',
    '.JPEG',
    '.PNG',
    '.WEBP'
  ];

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    try {
      // کل AssetManifest را بخوان
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifest = json.decode(manifestContent);

      // فقط مسیرهای داخل assets/img/gallery/ و با پسوند مجاز
      final allGalleryAssets = manifest.keys.where((k) {
        if (!k.startsWith('assets/img/gallery/')) return false;
        return _allowedExt.any((ext) => k.endsWith(ext));
      });

      // گروه‌بندی بر اساس نام دسته (اولین قطعه بعد از gallery/)
      final Map<String, List<String>> grouped = {};
      for (final path in allGalleryAssets) {
        final rest = path.substring('assets/img/gallery/'.length);
        final slash = rest.indexOf('/');
        if (slash <= 0) continue;
        final slug = rest.substring(0, slash);
        grouped.putIfAbsent(slug, () => []).add(path);
      }

      // مرتب‌سازی هر لیست برای نمایش پایدار
      for (final e in grouped.entries) {
        e.value.sort();
      }

      // اگر چیزی پیدا نشد، خطا بده تا سریع متوجه شویم
      if (grouped.isEmpty) {
        throw Exception('No gallery assets found under assets/img/gallery/');
      }

      // مرتب‌سازی کلیدها مطابق ترتیب دلخواه، سپس بقیه
      final orderedKeys = [
        ..._preferredOrder.where(grouped.keys.toSet().contains),
        ...grouped.keys.where((k) => !_preferredOrder.contains(k)).toList()
          ..sort(),
      ];

      final Map<String, List<String>> ordered = {
        for (final k in orderedKeys) k: grouped[k]!,
      };

      if (!mounted) return;
      setState(() {
        _imagesByCategory = ordered;
        _tabController?.dispose();
        _tabController =
            TabController(length: _imagesByCategory.length, vsync: this);
      });
    } catch (e) {
      debugPrint('Error loading gallery images: $e');
      if (!mounted) return;
      setState(() {
        _imagesByCategory = {
          'general': const [], // اجازه می‌دهد صفحه بالا بیاید، ولی خالی
        };
        _tabController?.dispose();
        _tabController =
            TabController(length: _imagesByCategory.length, vsync: this);
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
    final keys = _imagesByCategory.keys.toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('گالری تصاویر'),
        bottom: _tabController == null
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: [
                  for (final k in keys)
                    Tab(text: _faLabel[k] ?? k), // لیبل فارسی اگر وجود داشت
                ],
              ),
      ),
      body: _tabController == null
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                for (final k in keys) _buildGrid(_imagesByCategory[k]!),
              ],
            ),
    );
  }

  Widget _buildGrid(List<String> paths) {
    if (paths.isEmpty) {
      return const Center(
          child: Text('هیچ تصویری یافت نشد', style: TextStyle(fontSize: 16)));
    }
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: paths.length,
        itemBuilder: (context, i) {
          final p = paths[i];
          return GestureDetector(
            onTap: () => _showFullScreen(context, p),
            child: Hero(
              tag: p,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _imageWidget(p),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _imageWidget(String assetPath) {
    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      // وقتی Asset رجیستر نشده/مسیر اشتباه باشد:
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error loading image: $assetPath -> $error');
        return Container(
          color: Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.broken_image, size: 40, color: Colors.grey),
              const SizedBox(height: 8),
              Text('خطا در بارگذاری',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  textAlign: TextAlign.center),
            ],
          ),
        );
      },
    );
  }

  void _showFullScreen(BuildContext context, String assetPath) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(12),
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Hero(
              tag: assetPath,
              child: InteractiveViewer(child: _imageWidget(assetPath)),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
