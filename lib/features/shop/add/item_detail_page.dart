import 'package:flutter/material.dart';

class ItemDetailPage extends StatelessWidget {
  final Map<String, dynamic> item;

  const ItemDetailPage({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       title: const Text(
          'รายละเอียดสินค้า',
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item['item_photo'] != null)
              Container(
                height: 300,
                width: double.infinity,
                child: Image.network(
                  'http://192.168.31.218:3000/uploads/${item['item_photo']}',
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16.0),
            Text('${item['item_name']}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text('${item['item_type']}'),
            Text('Detail: ${item['item_detail']}'),
            Text('Description: ${item['item_description']}'),
            Text('Price: ${item['item_price']}'),
          ],
        ),
      ),
    );
  }
}
