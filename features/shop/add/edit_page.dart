import 'package:flutter/material.dart';

class EditPage extends StatelessWidget {
  const EditPage({super.key, required Map<String, dynamic> item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text(
          'แก้ไขโพส',
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
            'เนื้อหาการแก้ไขโพส',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}