import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    
    // تنظیم انیمیشن fade
    _fadeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    // شروع انیمیشن fade-in
    _fadeController.forward();
    
    // شبیه‌سازی لود شدن داده‌ها
    _loadData();
  }

  Future<void> _loadData() async {
    // در اینجا می‌توانید داده‌های واقعی را لود کنید
    // برای مثال: محصولات، دسته‌بندی‌ها، تنظیمات و...
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      setState(() {
        _isDataLoaded = true;
      });
      
      // fade-out و انتقال به صفحه اصلی
      await _fadeController.reverse();
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // تصویر لودینگ
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/img/etc/login-wait.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // متن لودینگ
              Text(
                'سیفی مارکت',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                  fontFamily: 'Vazirmatn',
                ),
              ),
              
              const SizedBox(height: 20),
              
              // نشانگر بارگذاری
              if (!_isDataLoaded)
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                ),
              
              const SizedBox(height: 20),
              
              // متن وضعیت
              Text(
                _isDataLoaded ? 'آماده است...' : 'در حال بارگذاری...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontFamily: 'Vazirmatn',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
