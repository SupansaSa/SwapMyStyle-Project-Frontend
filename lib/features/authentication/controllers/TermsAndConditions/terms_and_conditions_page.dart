import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

    @override
    Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // เอาปุ่มลูกศรออก
        title: Container(
          
          child: const Text(
            'ข้อกำหนดและเงื่อนไขการให้บริการ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context); // กลับไปหน้า login
            },
          ),
        ],
        toolbarHeight: 100, // เพิ่มความสูงของ AppBar ถ้าจำเป็น
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'เนื้อหาข้อกำหนดและเงื่อนไขการให้บริการ',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}