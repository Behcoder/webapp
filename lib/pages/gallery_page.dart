import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});
  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> with TickerProviderStateMixin {
  TabController? _tabController;
  Map<String, List<String>> _imagesByCategory = {};

  // برچسب‌های فارسی اختیاری برای اسلاگ‌ها
  static const Map<String, String> _faLabel = {
    'general': 'عمومی',
    'API': 'API',
    'galvanized': 'گالوانیزه',
    'gas': 'گازی',
    'spiral': 'اسپیراال',
    'manismann': 'مانیسمان',
    'scaffold': 'اسکافولد',
    'etc': 'متفرقه',
  };

  // ترتیب پیشنهادی تب‌ها؛ بقیه الفبایی می‌آیند
  static const List<String> _preferredOrder = [
    'general', 'API', 'galvanized', 'gas', 'spiral', 'manismann', 'scaffold', 'etc'
  ];

  // پسوندهای مجاز
  static const List<String> _allowedExt = [
    '.jpg', '.jpeg', '.png', '.webp', '.JPG', '.JPEG', '.PNG', '.WEBP'
  ];

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    try {
      // تمام دارایی‌های رجیسترشده در pubspec.yaml
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifest = json.decode(manifestContent);

      // لاگ‌های دیباگ (می‌توانی بعد از درست شدن حذف‌شان کنی)
      debugPrint('Total assets in manifest: ${manifest.keys.length}');
      final galleryKeys = manifest.keys.where((k) => k.startsWith('assets/gallery/')).toList();
      debugPrint('Gallery assets count: ${galleryKeys.length}');
      if (galleryKeys.isNotEmpty) {
        debugPrint('First 10 gallery assets: ${galleryKeys.take(10).toList()}');
      }

      // فقط مسیرهایی که زیر assets/gallery/ هستند و پسوند مجاز دارند
      final allGalleryAssets = manifest.keys.where((k) {
        if (!k.startsWith('assets/gallery/')) return false;
        return _allowedExt.any((ext) => k.endsWith(ext));
      });

      // گروه‌بندی بر اساس نام دسته: assets/gallery/<category>/<file>
      final Map<String, List<String>> grouped = {};
      for (final path in allGalleryAssets) {
        final rest = path.substring('assets/gallery/'.length);
        final slash = rest.indexOf('/');
        if (slash <= 0) continue;
        final slug = rest.substring(0, slash);
        grouped.putIfAbsent(slug, () => []).add(path);
      }

      // مرتب‌سازی آیتم‌های هر دسته برای نمایش پایدار
      for (final e in grouped.entries) {
        e.value.sort();
      }

      if (grouped.isEmpty) {
        // هیچ تصویری پیدا نشد
        if (!mounted) return;
        setState(() {
          _imagesByCategory = {};
          _tabController?.dispose();
          _tabController = null;
        });
        return;
      }

      // ترتیب‌دهی تب‌ها
      final orderedKeys = [
        ..._preferredOrder.where(grouped.keys.toSet().contains),
        ...grouped.keys.where((k) => !_preferredOrder.contains(k)).toList()..sort(),
      ];

      if (!mounted) return;
      setState(() {
        _imagesByCategory = {for (final k in orderedKeys) k: grouped[k]!};
        _tabController?.dispose();
        _tabController = TabController(length: _imagesByCategory.length, vsync: this);
      });
    } catch (e, st) {
      debugPrint('Error loading gallery images: $e\n$st');
      if (!mounted) return;
      setState(() {
        _imagesByCategory = {};
        _tabController?.dispose();
        _tabController = null;
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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('گالری تصاویر'),
          bottom: (_tabController == null || keys.isEmpty)
              ? null
              : TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: [for (final k in keys) Tab(text: _faLabel[k] ?? k)],
                ),
        ),
        body: _tabController == null
            ? const _EmptyView()
            : TabBarView(
                controller: _tabController,
                children: [for (final k in keys) _buildGrid(_imagesByCategory[k]!)],
              ),
      ),
    );
  }

  Widget _buildGrid(List<String> paths) {
    if (paths.isEmpty) {
      return const _EmptyView();
    }
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8,
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
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error loading image: $assetPath -> $error');
        return Container(
          color: Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.broken_image, size: 40),
              SizedBox(height: 8),
              Text('خطا در بارگذاری', style: TextStyle(fontSize: 12)),
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
            Hero(tag: assetPath, child: InteractiveViewer(child: _imageWidget(assetPath))),
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

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('هیچ تصویری یافت نشد'));
    // اگر دوست داری لودر بگذاری، می‌توانی اینجا تغییر بدهی.
  }
}
