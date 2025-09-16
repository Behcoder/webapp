import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'dart:math';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:intl/intl.dart'; // برای فرمت کردن قیمت‌ها
import 'constants/app_texts.dart';
import 'pages/static_content_page.dart';
import 'pages/contact_us_page.dart';
import 'pages/no_internet_page.dart';
import 'pages/error_page.dart';
import 'pages/gallery_page.dart';
import 'pages/search_page.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'services/connectivity_service.dart';
import 'utils/price_formatter.dart';
import 'utils/persian_number_formatter.dart';
import 'widgets/error_handler.dart';
// removed url_utils

// تابع کمکی برای فرمت کردن قیمت با جداکننده هزارگان و اعداد فارسی
String formatPrice(double price) {
  final formatter = NumberFormat('#,###');
  final formattedPrice = formatter.format(price.round());
  return '${PersianNumberFormatter.convertToPersian(formattedPrice)} ریال';
}

// ==========================================
// [main.dart-main]
// ==========================================
// توضیحات: نقطه ورود برنامه
// وابستگی‌ها: MyApp
// ==========================================
void main() async {
  // راه‌اندازی مدیریت خطاهای عمومی
  GlobalErrorHandler.setupErrorHandling();

  // تنظیم ErrorWidget builder برای production
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return GlobalErrorHandler.buildErrorWidget(details);
  };

  try {
    await dotenv.load(fileName: "assets/config.env");
  } catch (e) {
    debugPrint('Warning: Could not load config.env file: $e');
  }
  runApp(const MyApp());
}

// ==========================================
// [main.dart-MyApp]
// ==========================================
// توضیحات: تنظیمات اصلی برنامه شامل تم، زبان و صفحه اصلی
// وابستگی‌ها: MaterialApp, ThemeData, HomePage
// نکات مهم: تنظیمات زبان فارسی و فونت Vazirmatn
// ==========================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const appVersion = '۱.۶.۲۴'; // اعداد فارسی
    return MaterialApp(
      title: 'سیفی مارکت $appVersion',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        fontFamily: GoogleFonts.vazirmatn().fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        textTheme: GoogleFonts.vazirmatnTextTheme(),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fa', '')],
      locale: const Locale('fa', ''),
      home: const ConnectivityWrapper(),
    );
  }
}

class ConnectivityWrapper extends StatefulWidget {
  const ConnectivityWrapper({super.key});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  bool _isConnected = true;
  bool _isLoading = true;
  String? _errorMessage;
  late StreamSubscription<bool> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
  }

  Future<void> _initializeConnectivity() async {
    try {
      await ConnectivityService().initialize();
      _connectivitySubscription = ConnectivityService().connectivityStream
          .listen((isConnected) {
            if (mounted) {
              setState(() {
                _isConnected = isConnected;
                _isLoading = false;
                _errorMessage = null;
              });
            }
          });

      // بررسی اولیه
      final isConnected = await ConnectivityService().checkConnectivity();
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnected = false;
          _isLoading = false;
          _errorMessage = 'خطا در بررسی اتصال اینترنت: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return ErrorPage(
        message: _errorMessage,
        onRetry: () async {
          setState(() {
            _isLoading = true;
            _errorMessage = null;
          });
          await _initializeConnectivity();
        },
      );
    }

    if (!_isConnected) {
      return const NoInternetPage();
    }

    return const HomePage();
  }
}

// ==========================================
// [main.dart-CustomHeader]
// ==========================================
// توضیحات: هدر سفارشی صفحه اصلی شامل لوگو و جستجو
// وابستگی‌ها: Image.asset, TextField, SearchPage
// ==========================================
class CustomHeader extends StatelessWidget {
  const CustomHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Image.asset(
                'assets/img/logo/logo.png',
                height: 40,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchPage(),
                      ),
                    );
                  },
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(width: 16),
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          'جستجو...',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// [main.dart-HomePage]
// ==========================================
// توضیحات: صفحه اصلی برنامه شامل اسلایدر، دسته‌بندی‌ها و محصولات
// وابستگی‌ها: CustomHeader, BannerSlider, CategoryMenu, FeaturedProducts, NewProducts, Footer
// ==========================================
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomHeader(),
              BannerSlider(),
              // CategoryMenu(), // Removed CategoryMenu
              // New section for Parent Categories
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'دسته‌بندی‌های اصلی',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ParentCategoryGrid(),
              FeaturedProducts(),
              NewProducts(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Footer(),
    );
  }
}

// ==========================================
// [main.dart-Footer]
// ==========================================
// توضیحات: فوتر برنامه شامل لینک‌ها و اطلاعات تماس
// وابستگی‌ها: Row, Column, TextButton
// ==========================================
class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade900,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFooterItem(Icons.home, 'خانه', () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              }),
              _buildFooterItem(Icons.category, 'دسته‌بندی‌ها', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CategoriesPage(),
                  ),
                );
              }),
              _buildFooterItem(Icons.photo_library, 'گالری تصاویر', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GalleryPage()),
                );
              }),
              _buildFooterItem(Icons.contact_phone, 'تماس با ما', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContactUsPage(),
                  ),
                );
              }),
              _buildFooterItem(Icons.info_outline, 'درباره ما', () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildAboutItem(Icons.info_outline, 'درباره ما', () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StaticContentPage(
                                title: 'درباره ما',
                                content: AppTexts.aboutUs,
                              ),
                            ),
                          );
                        }),
                        _buildAboutItem(Icons.privacy_tip, 'حریم خصوصی', () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StaticContentPage(
                                title: 'حریم خصوصی',
                                content: AppTexts.privacyPolicy,
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterItem(IconData icon, String label, VoidCallback onPressed) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue.shade900, size: 24),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// [main.dart-BannerSlider]
// ==========================================
// توضیحات: اسلایدر بنر با قابلیت اسلاید خودکار
// وابستگی‌ها: PageView.builder
// ==========================================
class BannerSlider extends StatelessWidget {
  const BannerSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.9),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/img/banner/${index + 1}.png',
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// [main.dart-FeaturedProducts]
// ==========================================
// توضیحات: نمایش محصولات ویژه
// وابستگی‌ها: ListView.separated
// ==========================================
class FeaturedProducts extends StatefulWidget {
  const FeaturedProducts({super.key});

  @override
  State<FeaturedProducts> createState() => _FeaturedProductsState();
}

class _FeaturedProductsState extends State<FeaturedProducts> {
  List products = [];
  bool isLoading = true;
  String? errorMsg;
  int? featuredCategoryId;
  final ScrollController _scrollController = ScrollController();
  Timer? _autoScrollTimer;
  bool _scrollingForward = true; // Added to track scroll direction

  @override
  void initState() {
    super.initState();
    fetchFeaturedCategory();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;

        double nextScroll;
        if (_scrollingForward) {
          nextScroll =
              currentScroll + 132; // 120 (item width) + 12 (padding/spacing)
          if (nextScroll >= maxScroll) {
            _scrollingForward = false; // Change direction
            const bounceOffset = 20.0;
            _scrollController
                .animateTo(
                  maxScroll + bounceOffset, // Overshoot
                  duration: const Duration(
                    milliseconds: 200,
                  ), // Quick overshoot
                  curve: Curves.easeOut,
                )
                .then((_) {
                  _scrollController.animateTo(
                    maxScroll, // Bounce back
                    duration: const Duration(
                      milliseconds: 300,
                    ), // Slower bounce back
                    curve: Curves.easeIn,
                  );
                });
            return;
          }
        } else {
          nextScroll = currentScroll - 132; // Scroll backward
          if (nextScroll <= 0) {
            _scrollingForward = true; // Change direction
            const bounceOffset = 20.0;
            _scrollController
                .animateTo(
                  -bounceOffset, // Overshoot
                  duration: const Duration(
                    milliseconds: 200,
                  ), // Quick overshoot
                  curve: Curves.easeOut,
                )
                .then((_) {
                  _scrollController.animateTo(
                    0, // Bounce back
                    duration: const Duration(
                      milliseconds: 300,
                    ), // Slower bounce back
                    curve: Curves.easeIn,
                  );
                });
            return;
          }
        }

        _scrollController.animateTo(
          nextScroll,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> fetchFeaturedCategory() async {
    final url = Uri.parse(
      'https://seify.ir/wp-json/wc/v3/products/categories?consumer_key=ck_278d4ac63be04448206d8aec329301bd58831670&consumer_secret=cs_c4d143188011db4cce3137dd7c046c435f18114b&per_page=100',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final categories = json.decode(response.body) as List;
        final featuredCategory = categories.firstWhere(
          (cat) =>
              cat['name'] == 'محصولات ویژه اپ' ||
              cat['slug'] == 'featured-app-products',
          orElse: () => null,
        );

        if (featuredCategory != null) {
          setState(() {
            featuredCategoryId = featuredCategory['id'];
          });
          fetchFeaturedProducts();
        } else {
          setState(() {
            isLoading = false;
            errorMsg = 'دسته‌بندی محصولات ویژه یافت نشد';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMsg = 'خطا در دریافت اطلاعات: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMsg = 'خطا در ارتباط با سرور: $e';
      });
    }
  }

  Future<void> fetchFeaturedProducts() async {
    if (featuredCategoryId == null) return;

    final url = Uri.parse(
      'https://seify.ir/wp-json/wc/v3/products?consumer_key=ck_278d4ac63be04448206d8aec329301bd58831670&consumer_secret=cs_c4d143188011db4cce3137dd7c046c435f18114b&per_page=100&category=$featuredCategoryId',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          products = json.decode(response.body);
          isLoading = false;
          errorMsg = null;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMsg = 'خطا در دریافت محصولات: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMsg = 'خطا در ارتباط با سرور: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMsg != null) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(errorMsg!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    if (products.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('محصول ویژه‌ای یافت نشد')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'محصولات ویژه',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductsPage(
                        categoryId: featuredCategoryId!,
                        categoryName: 'محصولات ویژه',
                      ),
                    ),
                  );
                },
                child: const Text('مشاهده همه'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 260, // افزایش برای نمایش کامل متن در موبایل
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product =
                  products[index]; // Use original index as we are now bouncing
              final imageUrl = product['images']?.isNotEmpty == true
                  ? product['images'][0]['src']
                  : null;
              final price = product['price'] != null
                  ? double.tryParse(product['price'])
                  : null;
              final regularPrice = product['regular_price'] != null
                  ? double.tryParse(product['regular_price'])
                  : null;
              final hasDiscount =
                  regularPrice != null && price != null && regularPrice > price;

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                ), // Adjusted padding for consistent spacing
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailPage(product: product),
                      ),
                    );
                  },
                  child: Container(
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (imageUrl != null)
                          Container(
                            height: 120, // کاهش برای جلوگیری از overflow
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white,
                                  Colors.grey.withOpacity(0.1),
                                ],
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: Image.network(
                                imageUrl,
                                width: double.infinity,
                                height: 120,
                                fit: BoxFit
                                    .cover, // تغییر به cover برای responsive بودن
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[100],
                                    child: const Icon(
                                      Icons.image,
                                      color: Colors.grey,
                                      size: 40,
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                        else
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            child: const Icon(
                              Icons.image,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(
                            12,
                          ), // افزایش padding برای فضای بیشتر
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 13, // افزایش اندازه فونت
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 3, // اجازه 3 خط برای نام محصول
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(
                                height: 8,
                              ), // افزایش فضای بین نام و قیمت
                              if (price != null)
                                Row(
                                  children: [
                                    Flexible(
                                      // اضافه کردن Flexible برای جلوگیری از overflow
                                      child: Text(
                                        '${formatPrice(price)}',
                                        style: TextStyle(
                                          fontSize: 13, // افزایش اندازه فونت
                                          fontWeight: FontWeight.bold,
                                          color: hasDiscount
                                              ? Colors.red
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    if (hasDiscount) ...[
                                      const SizedBox(width: 4),
                                      Text(
                                        regularPrice.toStringAsFixed(0),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ==========================================
// [main.dart-NewProducts]
// ==========================================
// توضیحات: نمایش محصولات جدید
// وابستگی‌ها: ListView.separated
// ==========================================
class NewProducts extends StatefulWidget {
  const NewProducts({super.key});

  @override
  State<NewProducts> createState() => _NewProductsState();
}

class _NewProductsState extends State<NewProducts> {
  List products = [];
  List randomProducts = [];
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    fetchLatestProducts();
  }

  List<T> getRandomItems<T>(List<T> list, int count) {
    if (list.length <= count) return list;

    // Use current date as seed for random number generation
    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final random = Random(seed);

    final shuffled = List<T>.from(list);
    for (var i = shuffled.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = shuffled[i];
      shuffled[i] = shuffled[j];
      shuffled[j] = temp;
    }

    return shuffled.take(count).toList();
  }

  Future<void> fetchLatestProducts() async {
    final url = Uri.parse(
      'https://seify.ir/wp-json/wc/v3/products?consumer_key=ck_278d4ac63be04448206d8aec329301bd58831670&consumer_secret=cs_c4d143188011db4cce3137dd7c046c435f18114b&per_page=100&orderby=date&order=desc',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final allProducts = json.decode(response.body);
        setState(() {
          products = allProducts;
          randomProducts = getRandomItems(allProducts, 7);
          isLoading = false;
          errorMsg = null;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMsg = 'خطا در دریافت محصولات: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMsg = 'خطا در ارتباط با سرور: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMsg != null) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(errorMsg!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    if (randomProducts.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('محصولی یافت نشد')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'محصولات پیشنهادی',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProductsPage(
                        categoryId: null,
                        categoryName: 'محصولات پیشنهادی',
                      ),
                    ),
                  );
                },
                child: const Text('مشاهده همه'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 260, // افزایش برای نمایش کامل متن در موبایل
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: randomProducts.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = randomProducts[index];
              final imageUrl = product['images']?.isNotEmpty == true
                  ? product['images'][0]['src']
                  : null;
              final price = product['price'] != null
                  ? double.tryParse(product['price'])
                  : null;
              final regularPrice = product['regular_price'] != null
                  ? double.tryParse(product['regular_price'])
                  : null;
              final hasDiscount =
                  regularPrice != null && price != null && regularPrice > price;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(product: product),
                    ),
                  );
                },
                child: Container(
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageUrl != null)
                        Container(
                          height: 120, // کاهش برای جلوگیری از overflow
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white,
                                Colors.grey.withOpacity(0.1),
                              ],
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: Image.network(
                              imageUrl,
                              width: double.infinity,
                              fit: BoxFit
                                  .cover, // پر کردن کامل کادر بر اساس بزرگترین ضلع
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[100],
                                  child: const Icon(
                                    Icons.image,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      else
                        Container(
                          height: 120, // هماهنگ با container تصویر
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.grey[50]!, Colors.grey[100]!],
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_outlined,
                                color: Colors.grey,
                                size: 48,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'بدون تصویر',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(
                          12,
                        ), // افزایش padding برای فضای بیشتر
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'] ?? '',
                              style: const TextStyle(
                                fontSize: 13, // افزایش اندازه فونت
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 3, // اجازه 3 خط برای نام محصول
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(
                              height: 8,
                            ), // افزایش فضای بین نام و قیمت
                            if (price != null)
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${formatPrice(price)}',
                                      style: TextStyle(
                                        fontSize: 13, // افزایش اندازه فونت
                                        fontWeight: FontWeight.bold,
                                        color: hasDiscount
                                            ? Colors.red
                                            : Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (hasDiscount) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      PersianNumberFormatter.convertToPersian(
                                        regularPrice.toStringAsFixed(0),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ==========================================
// [main.dart-CategoriesPage]
// ==========================================
// توضیحات: صفحه دسته‌بندی‌ها
// وابستگی‌ها: GridView.builder, http
// ==========================================
class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List mainCategories = [];
  List subCategories = [];
  bool isLoading = true;
  String? errorMsg;
  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    fetchMainCategories();
  }

  Future<void> fetchMainCategories() async {
    final url = Uri.parse(
      'https://seify.ir/wp-json/wc/v3/products/categories?consumer_key=ck_278d4ac63be04448206d8aec329301bd58831670&consumer_secret=cs_c4d143188011db4cce3137dd7c046c435f18114b&per_page=100&parent=0',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final allCategories = json.decode(response.body) as List;

        // فیلتر کردن دسته‌بندی‌های خالی (بدون محصول)
        List nonEmptyCategories = [];
        for (var category in allCategories) {
          final categoryId = category['id'];
          final productsUrl = Uri.parse(
            'https://seify.ir/wp-json/wc/v3/products?consumer_key=ck_278d4ac63be04448206d8aec329301bd58831670&consumer_secret=cs_c4d143188011db4cce3137dd7c046c435f18114b&category=$categoryId&per_page=1',
          );

          try {
            final productsResponse = await http.get(productsUrl);
            if (productsResponse.statusCode == 200) {
              final products = json.decode(productsResponse.body) as List;
              if (products.isNotEmpty) {
                nonEmptyCategories.add(category);
              }
            }
          } catch (e) {
            // در صورت خطا، دسته‌بندی را نادیده می‌گیریم
            continue;
          }
        }

        setState(() {
          mainCategories = nonEmptyCategories;
          isLoading = false;
          errorMsg = null;
          if (mainCategories.isNotEmpty) {
            selectedCategoryId = mainCategories[0]['id'];
            fetchSubCategories(selectedCategoryId!);
          }
        });
      } else {
        setState(() {
          isLoading = false;
          errorMsg = 'خطا در دریافت اطلاعات: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMsg = 'خطا در ارتباط با سرور: $e';
      });
    }
  }

  Future<void> fetchSubCategories(int parentId) async {
    final url = Uri.parse(
      'https://seify.ir/wp-json/wc/v3/products/categories?consumer_key=ck_278d4ac63be04448206d8aec329301bd58831670&consumer_secret=cs_c4d143188011db4cce3137dd7c046c435f18114b&per_page=100&parent=$parentId',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final allSubCategories = json.decode(response.body) as List;

        // فیلتر کردن زیر دسته‌بندی‌های خالی (بدون محصول)
        List nonEmptySubCategories = [];
        for (var category in allSubCategories) {
          final categoryId = category['id'];
          final productsUrl = Uri.parse(
            'https://seify.ir/wp-json/wc/v3/products?consumer_key=ck_278d4ac63be04448206d8aec329301bd58831670&consumer_secret=cs_c4d143188011db4cce3137dd7c046c435f18114b&category=$categoryId&per_page=1',
          );

          try {
            final productsResponse = await http.get(productsUrl);
            if (productsResponse.statusCode == 200) {
              final products = json.decode(productsResponse.body) as List;
              if (products.isNotEmpty) {
                nonEmptySubCategories.add(category);
              }
            }
          } catch (e) {
            // در صورت خطا، دسته‌بندی را نادیده می‌گیریم
            continue;
          }
        }

        setState(() {
          subCategories = nonEmptySubCategories;
        });
      }
    } catch (e) {
      debugPrint('Error fetching subcategories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دسته‌بندی محصولات'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMsg != null
          ? Center(
              child: Text(errorMsg!, style: const TextStyle(color: Colors.red)),
            )
          : mainCategories.isEmpty
          ? const Center(child: Text('دسته‌بندی‌ای یافت نشد'))
          : Row(
              children: [
                // ستون راست - دسته‌های اصلی (ثابت)
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 140,
                    maxWidth: 180,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border(
                      left: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: ListView.builder(
                    itemCount: mainCategories.length,
                    itemBuilder: (context, index) {
                      final cat = mainCategories[index];
                      final isSelected = cat['id'] == selectedCategoryId;
                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: Colors.blue.shade50,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        leading:
                            cat['image'] != null && cat['image']['src'] != null
                            ? Image.network(
                                cat['image']['src'],
                                width: 32,
                                height: 32,
                                fit: BoxFit.cover,
                              )
                            : Icon(
                                Icons.category,
                                color: isSelected ? Colors.blue : Colors.grey,
                                size: 24,
                              ),
                        title: Text(
                          cat['name'] ?? '',
                          style: TextStyle(
                            color: isSelected ? Colors.blue : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            selectedCategoryId = cat['id'];
                          });
                          fetchSubCategories(cat['id']);
                        },
                      );
                    },
                  ),
                ),
                // ستون چپ - زیر دسته‌ها (دینامیک)
                Expanded(
                  child: subCategories.isEmpty
                      ? const Center(
                          child: Text('یک دسته‌بندی را انتخاب نمایید'),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.8,
                              ),
                          itemCount: subCategories.length,
                          itemBuilder: (context, index) {
                            final cat = subCategories[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductsPage(
                                      categoryId: cat['id'],
                                      categoryName: cat['name'],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withValues(alpha: 0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      child:
                                          cat['image'] != null &&
                                              cat['image']['src'] != null
                                          ? Image.network(
                                              cat['image']['src'],
                                              height: 100,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            )
                                          : Container(
                                              height: 100,
                                              color: Colors.grey.shade200,
                                              child: Center(
                                                child: Icon(
                                                  Icons.category,
                                                  size: 40,
                                                  color: Colors.grey.shade400,
                                                ),
                                              ),
                                            ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cat['name'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${PersianNumberFormatter.convertToPersian('${cat['count'] ?? 0}')} محصول',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      bottomNavigationBar: const Footer(),
    );
  }
}

// ==========================================
// [main.dart-ProductsPage]
// ==========================================
// توضیحات: صفحه محصولات یک دسته‌بندی
// وابستگی‌ها: ListView.builder, http
// ==========================================
class ProductsPage extends StatefulWidget {
  final int? categoryId;
  final String categoryName;

  const ProductsPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List products = [];
  bool isLoading = true;
  String? errorMsg;
  int page = 1;
  bool hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
      products = []; // تمیز کردن لیست قبلی
      page = 1; // ریست کردن صفحه
    });

    String url =
        'https://seify.ir/wp-json/wc/v3/products?consumer_key=ck_278d4ac63be04448206d8aec329301bd58831670&consumer_secret=cs_c4d143188011db4cce3137dd7c046c435f18114b&per_page=20&page=$page';

    if (widget.categoryId != null) {
      url += '&category=${widget.categoryId}';
      debugPrint('Fetching products for category: ${widget.categoryId}');
    } else if (widget.categoryName == 'محصولات ویژه') {
      url += '&featured=true';
    }

    debugPrint('API URL: $url');

    try {
      final response = await http.get(Uri.parse(url));
      debugPrint('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final newProducts = json.decode(response.body) as List;
        debugPrint('Found ${newProducts.length} products');

        setState(() {
          products = newProducts; // تنظیم محصولات جدید
          hasMore = newProducts.length == 20;
          isLoading = false;
          errorMsg = null;
        });
      } else {
        debugPrint('Error response body: ${response.body}');
        setState(() {
          isLoading = false;
          errorMsg = 'خطا در دریافت محصولات: ${response.statusCode}';
        });
      }
    } catch (e) {
      debugPrint('Exception: $e');
      setState(() {
        isLoading = false;
        errorMsg = 'خطا در ارتباط با سرور: $e';
      });
    }
  }

  Widget _buildProductImage(Map product) {
    // لیست تصاویر محلی برای استفاده به عنوان جایگزین
    final List<String> fallbackImages = [
      'assets/img/gallery/products/DSC_1052.jpg',
      'assets/img/gallery/products/DSC_1054.jpg',
      'assets/img/gallery/products/DSC_1068.jpg',
    ];

    // انتخاب تصویر تصادفی از لیست محلی
    final randomIndex = product['id'] != null
        ? (product['id'] % fallbackImages.length)
        : 0;
    final fallbackImage = fallbackImages[randomIndex];

    if (product['images'] != null && product['images'].isNotEmpty) {
      return Image.network(
        product['images'][0]['src'],
        width: double.infinity,
        height: double.infinity, // پر کردن کامل فضای موجود
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          debugPrint(
            'Error loading product image: ${product['images'][0]['src']}',
          );
          // در صورت خطا، از تصویر محلی استفاده کن
          return Image.asset(
            fallbackImage,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.grey.shade200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image,
                      size: 32,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'خطا در بارگذاری',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 120,
            color: Colors.grey.shade200,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      );
    } else {
      // اگر تصویر محصول وجود ندارد، از تصویر محلی استفاده کن
      return Image.asset(
        fallbackImage,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey.shade200,
            child: Center(
              child: Icon(Icons.image, size: 48, color: Colors.grey.shade400),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMsg != null
          ? Center(
              child: Text(errorMsg!, style: const TextStyle(color: Colors.red)),
            )
          : products.isEmpty
          ? const Center(child: Text('محصولی یافت نشد'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600
                    ? 3
                    : 2, // Responsive crossAxisCount
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: MediaQuery.of(context).size.width > 600
                    ? 0.8
                    : 0.65, // Responsive aspect ratio
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailPage(product: product),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 140, // ارتفاع مشخص برای تصویر
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: _buildProductImage(product),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                PriceFormatter.formatStringPriceWithUnit(
                                  product['price'] ?? '0',
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: const Footer(),
    );
  }
}

// ==========================================
// [main.dart-ProductDetailPage]
// ==========================================
// توضیحات: صفحه جزئیات محصول
// وابستگی‌ها: CarouselSlider, http
// ==========================================
class ProductDetailPage extends StatefulWidget {
  final Map product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  List<Map<String, dynamic>> reviews = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> fetchReviews() async {
    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse(
        'https://seify.ir/wp-json/wc/v3/products/reviews?consumer_key=ck_278d4ac63be04448206d8aec329301bd58831670&consumer_secret=cs_c4d143188011db4cce3137dd7c046c435f18114b&product=${widget.product['id']}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          reviews = List<Map<String, dynamic>>.from(json.decode(response.body));
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('خطا در دریافت نظرات')));
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطا در ارتباط با سرور: $e')));
      }
    }
  }

  Future<void> submitReview() async {
    if (_reviewController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفا تمام فیلدها را پر کنید')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse(
        'https://seify.ir/wp-json/wc/v3/products/reviews?consumer_key=ck_278d4ac63be04448206d8aec329301bd58831670&consumer_secret=cs_c4d143188011db4cce3137dd7c046c435f18114b',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'product_id': widget.product['id'],
          'review': _reviewController.text,
          'reviewer': _nameController.text,
          'reviewer_email': _emailController.text,
          'rating': 5,
        }),
      );

      if (response.statusCode == 201) {
        _reviewController.clear();
        _nameController.clear();
        _emailController.clear();
        fetchReviews();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('نظر شما با موفقیت ثبت شد')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('خطا در ثبت نظر')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطا در ارتباط با سرور: $e')));
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.product['name'] ?? ''),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                // کپی کردن لینک محصول
                Clipboard.setData(
                  ClipboardData(
                    text: widget.product['permalink'] ?? 'https://seify.ir',
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('لینک محصول کپی شد')),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                // نمایش اطلاعات محصول
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('اطلاعات محصول'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('نام: ${widget.product['name'] ?? ''}'),
                        Text(
                          'قیمت: ${PriceFormatter.formatStringPriceWithUnit(widget.product['price'] ?? '')}',
                        ),
                        Text(
                          'وضعیت: ${widget.product['stock_status'] == 'instock' ? 'موجود' : 'ناموجود'}',
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('بستن'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.product['images'] != null &&
                  widget.product['images'].isNotEmpty)
                Column(
                  children: [
                    CarouselSlider(
                      items: widget.product['images'].map<Widget>((image) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  image['src'],
                                  fit: BoxFit
                                      .contain, // تغییر به contain برای نمایش کامل عکس با حفظ نسبت
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value:
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                  errorBuilder: (context, error, stackTrace) {
                                    debugPrint(
                                      'Error loading detail image: ${image['src']}',
                                    );
                                    return Container(
                                      height: 300,
                                      color: Colors.grey.shade200,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.broken_image,
                                            size: 64,
                                            color: Colors.grey.shade400,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'خطا در بارگذاری تصویر',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'لطفاً اتصال اینترنت خود را بررسی کنید',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade500,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                      options: CarouselOptions(
                        height: 300,
                        viewportFraction: 1.0,
                        enableInfiniteScroll: true,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 3),
                        autoPlayAnimationDuration: const Duration(
                          milliseconds: 800,
                        ),
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enlargeCenterPage: false,
                        scrollDirection: Axis.horizontal,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              Text(
                widget.product['name'] ?? '',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (widget.product['price'] != null &&
                  widget.product['price'] != '')
                Text(
                  'قیمت: ${PriceFormatter.formatStringPriceWithUnit(widget.product['price'] ?? '')}',
                  style: const TextStyle(fontSize: 18, color: Colors.green),
                ),
              const SizedBox(height: 16),
              if (widget.product['description'] != null &&
                  widget.product['description'] != '')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'توضیحات:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _parseHtmlString(widget.product['description']),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              if (widget.product['stock_status'] != null)
                Text(
                  'وضعیت موجودی: ${widget.product['stock_status'] == 'instock' ? 'موجود' : 'ناموجود'}',
                ),
              const SizedBox(height: 32),

              // Review Section
              const Text(
                'نظرات کاربران',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Review Form
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ثبت نظر جدید',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'نام',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'ایمیل',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _reviewController,
                        decoration: const InputDecoration(
                          labelText: 'نظر شما',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : submitReview,
                          child: isLoading
                              ? const CircularProgressIndicator()
                              : const Text('ثبت نظر'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Reviews List
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (reviews.isEmpty)
                const Center(child: Text('هنوز نظری ثبت نشده است'))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  review['reviewer'] ?? 'کاربر',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _formatDate(review['date_created']),
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(review['review'] ?? ''),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _parseHtmlString(String htmlString) {
    return htmlString
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}/${date.month}/${date.day}';
    } catch (e) {
      return dateStr;
    }
  }
}

// ==========================================
// [main.dart-ParentCategoryGrid]
// ==========================================
// توضیحات: نمایش دسته‌بندی‌های اصلی (بدون زیردسته) با تصویر
// وابستگی‌ها: ListView.builder
// ==========================================
class ParentCategoryGrid extends StatefulWidget {
  const ParentCategoryGrid({super.key});

  @override
  State<ParentCategoryGrid> createState() => _ParentCategoryGridState();
}

class _ParentCategoryGridState extends State<ParentCategoryGrid> {
  List categories = [];
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    fetchParentCategories();
  }

  Future<void> fetchParentCategories() async {
    final url = Uri.parse(
      'https://seify.ir/wp-json/wc/v3/products/categories?consumer_key=ck_278d4ac63be04448206d8aec329301bd58831670&consumer_secret=cs_c4d143188011db4cce3137dd7c046c435f18114b&parent=0',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final allCategories = json.decode(response.body) as List;

        // فیلتر کردن دسته‌بندی‌های خالی (بدون محصول)
        List nonEmptyCategories = [];
        for (var category in allCategories) {
          final categoryId = category['id'];
          final productsUrl = Uri.parse(
            'https://seify.ir/wp-json/wc/v3/products?consumer_key=ck_278d4ac63be04448206d8aec329301bd58831670&consumer_secret=cs_c4d143188011db4cce3137dd7c046c435f18114b&category=$categoryId&per_page=1',
          );

          try {
            final productsResponse = await http.get(productsUrl);
            if (productsResponse.statusCode == 200) {
              final products = json.decode(productsResponse.body) as List;
              if (products.isNotEmpty) {
                nonEmptyCategories.add(category);
              }
            }
          } catch (e) {
            // در صورت خطا، دسته‌بندی را نادیده می‌گیریم
            continue;
          }
        }

        setState(() {
          categories = nonEmptyCategories;
          isLoading = false;
          errorMsg = null;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMsg = 'خطا در دریافت دسته‌بندی‌ها: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMsg = 'خطا در ارتباط با سرور: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMsg != null) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Text(errorMsg!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    if (categories.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text('دسته‌بندی اصلی یافت نشد')),
      );
    }

    return SizedBox(
      height: 100, // Adjust height as needed
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final category = categories[index];
          final imageUrl =
              category['image'] != null && category['image']['src'] != null
              ? category['image']['src']
              : null;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductsPage(
                    categoryId: category['id'],
                    categoryName: category['name'],
                  ),
                ),
              );
            },
            child: Container(
              width: 100, // Same width as CategoryMenu items
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Icon(
                      Icons
                          .category, // Default icon for categories without image
                      size: 32,
                      color: Colors.blue.shade700,
                    ),
                  const SizedBox(height: 8),
                  Text(
                    category['name'] ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
