import 'package:flutter/material.dart';

class LikePage extends StatelessWidget {
  const LikePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'สินค้าที่ชื่นชอบ',
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
            'เพิ่มสินค้าที่ชื่นชอบของคุณ',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}