import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'นโยบายความเป็นส่วนตัว',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold, 
          ),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'เนื้อหานโยบายความเป็นส่วนตัว',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}