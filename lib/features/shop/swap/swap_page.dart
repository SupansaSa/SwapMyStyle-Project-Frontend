import 'package:flutter/material.dart';

class SwapPage extends StatelessWidget {
  const SwapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'การแลกเปลี่ยนสินค้า',
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
            'เนื้อหาการแลกเปลี่ยนสินค้า',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}