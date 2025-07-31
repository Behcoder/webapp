import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/connectivity_service.dart';

class NoInternetPage extends StatefulWidget {
  const NoInternetPage({super.key});

  @override
  State<NoInternetPage> createState() => _NoInternetPageState();
}

class _NoInternetPageState extends State<NoInternetPage> {
  bool _isChecking = false;

  Future<void> _checkConnection() async {
    setState(() {
      _isChecking = true;
    });

    try {
      final isConnected = await ConnectivityService().checkConnectivity();
      
      if (isConnected) {
        // اگر اتصال برقرار شد، به صفحه اصلی برو
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/');
        }
      } else {
        // اگر هنوز اتصال برقرار نیست، پیام نمایش بده
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('اتصال اینترنت هنوز برقرار نیست'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در بررسی اتصال: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // انیمیشن قطع اینترنت
            Lottie.asset(
              'assets/animations/no_internet.json',
              width: 200,
              height: 200,
              repeat: true,
            ),
            const SizedBox(height: 20),
            const Text(
              'اتصال اینترنت قطع شده است',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'لطفاً اتصال اینترنت خود را بررسی کنید و دوباره تلاش کنید',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _isChecking ? null : _checkConnection,
              icon: _isChecking 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
              label: Text(_isChecking ? 'در حال بررسی...' : 'تلاش مجدد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 