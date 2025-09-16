import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../main.dart'; // برای دسترسی به Footer
import 'contact_us_page.dart'; // برای دسترسی به ContactUsPage

class StaticContentPage extends StatelessWidget {
  final String title;
  final String content;

  const StaticContentPage({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildContent(context),
      ),
      bottomNavigationBar: const Footer(),
    );
  }

  Widget _buildContent(BuildContext context) {
    // تقسیم متن به خطوط و تشخیص شماره تلفن‌ها
    final lines = content.split('\n');
    List<Widget> widgets = [];

    for (String line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
      } else if (_isPhoneNumber(line.trim())) {
        widgets.add(_buildPhoneNumber(line.trim()));
      } else {
        widgets.add(_buildNormalText(line));
      }
    }

    // اضافه کردن دکمه زیبای تماس برای صفحه درباره ما
    if (title == 'درباره ما') {
      widgets.add(const SizedBox(height: 32));
      widgets.add(_buildContactButton(context));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  bool _isPhoneNumber(String text) {
    // تشخیص شماره تلفن (شامل شماره‌های ثابت و همراه)
    final phonePattern = RegExp(r'^0\d{2,3}-?\d{8}$|^09\d{9}$');
    return phonePattern.hasMatch(text.replaceAll('-', ''));
  }

  Widget _buildPhoneNumber(String phoneNumber) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () => _makePhoneCall(phoneNumber),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade100,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.phone, color: Colors.blue.shade700, size: 18),
              const SizedBox(width: 8),
              Text(
                phoneNumber,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
                textDirection: TextDirection.ltr,
              ),
              const SizedBox(width: 8),
              Icon(Icons.call, color: Colors.green.shade600, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNormalText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, height: 1.6),
        textAlign: TextAlign.justify,
        textDirection: TextDirection.rtl,
      ),
    );
  }

  Widget _buildContactButton(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ContactUsPage()),
            );
          },
          icon: const Icon(Icons.phone_in_talk, color: Colors.white, size: 24),
          label: const Text(
            'اطلاعات تماس',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            shadowColor: Colors.green.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber.replaceAll('-', ''),
    );

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    } catch (e) {
      debugPrint('خطا در باز کردن شماره تلفن: $e');
    }
  }
}
