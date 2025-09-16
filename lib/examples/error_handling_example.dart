import 'package:flutter/material.dart';
import '../widgets/error_boundary.dart';
import '../widgets/error_handler.dart';

// Example of how to use ErrorBoundary with any page that might have errors
class ExampleUsage extends StatelessWidget {
  const ExampleUsage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مثال استفاده از مدیریت خطا')),
      body: ErrorBoundary(
        child: Column(
          children: [
            const Text('این صفحه از ErrorBoundary محافظت می‌شود'),
            ElevatedButton(
              onPressed: () {
                // این یک خطای تست است
                throw Exception('خطای تست');
              },
              child: const Text('تست خطا'),
            ),
            // محتوای اصلی صفحه...
          ],
        ),
      ),
    );
  }
}

// مثال استفاده در CategoriesPage
class SafeCategoriesPage extends StatelessWidget {
  const SafeCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('دسته‌بندی محصولات'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('محتوای صفحه دسته‌بندی‌ها با محافظت خطا'),
        ),
      ),
    );
  }
}
