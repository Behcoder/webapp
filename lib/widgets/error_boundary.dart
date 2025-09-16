import 'package:flutter/material.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget? errorWidget;

  const ErrorBoundary({Key? key, required this.child, this.errorWidget})
    : super(key: key);

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Reset error state when widget is created
    _hasError = false;
  }

  void _handleError(Object error, StackTrace stackTrace) {
    setState(() {
      _hasError = true;
    });
  }

  void _retry() {
    setState(() {
      _hasError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.errorWidget ?? _buildDefaultErrorWidget();
    }

    // Wrap child in error handling
    return Builder(
      builder: (context) {
        try {
          return widget.child;
        } catch (error, stackTrace) {
          _handleError(error, stackTrace);
          return _buildDefaultErrorWidget();
        }
      },
    );
  }

  Widget _buildDefaultErrorWidget() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.refresh, size: 80, color: Colors.orange[300]),
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
                onPressed: _retry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('تلاش مجدد', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
