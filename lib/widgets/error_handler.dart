import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui';

class GlobalErrorHandler {
  /// Setup global error handling for the app
  static void setupErrorHandling() {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      if (kDebugMode) {
        // In debug mode, show the default error screen for developers
        FlutterError.presentError(details);
      } else {
        // In production, just log the error
        debugPrint('Flutter Error: ${details.exception}');
      }
    };

    // Handle platform errors (iOS/Android specific errors)
    PlatformDispatcher.instance.onError = (error, stack) {
      if (kDebugMode) {
        debugPrint('Platform Error: $error');
        debugPrint('Stack: $stack');
      }
      return true;
    };
  }

  /// Build a user-friendly error widget for production
  static Widget buildErrorWidget(FlutterErrorDetails details) {
    if (kDebugMode) {
      // In debug mode, show the default Flutter error widget
      return ErrorWidget(details.exception);
    } else {
      // In production, show user-friendly error message
      return ProductionErrorWidget();
    }
  }
}

class ProductionErrorWidget extends StatelessWidget {
  const ProductionErrorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
              const SizedBox(height: 24),
              Text(
                'مشکلی پیش آمد',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 12),
              Text(
                'دوباره تلاش کنید',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Try to pop to previous screen or restart app
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    // If no previous screen, you might want to navigate to home
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('بازگشت', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
