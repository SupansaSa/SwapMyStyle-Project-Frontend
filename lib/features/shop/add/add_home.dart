import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/features/shop/add/add_item_page.dart';
import 'package:myapp/features/shop/add/item_detail_page.dart'; 

class AddHomePage extends StatefulWidget {
  const AddHomePage({Key? key}) : super(key: key);

  @override
  _AddHomePageState createState() => _AddHomePageState();
}

class _AddHomePageState extends State<AddHomePage> {
  List<Map<String, dynamic>> _items = [];
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId(); 
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
    });
    if (userId != null) {
      _loadItems();
    }
  }

  Future<void> _loadItems() async {
    if (userId == null) return;
    final response = await http.get(Uri.parse('http://192.168.31.218:3000/getItems?userId=$userId'));

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        print('Received data: $data'); // พิมพ์ข้อมูลที่ได้รับ
        final List<dynamic> items = data['items'];
        setState(() {
          _items = List<Map<String, dynamic>>.from(items);
        });
      } catch (e) {
        print('Failed to parse JSON: $e'); // พิมพ์ข้อผิดพลาดในการแปลง JSON
      }
    } else {
      print('Failed to load items: ${response.statusCode}'); // พิมพ์สถานะโค้ดของการตอบกลับ
    }
  }

  void _navigateToAddItemPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddItemPage()),
    );

    if (result != null) {
      _loadItems(); // Reload items
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFE966A0),
        title: const Text(
          'My Items',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            color: Colors.white,
            onPressed: _navigateToAddItemPage,
          ),
        ],
      ),
      body: _items.isEmpty
          ? const Center(child: Text('No items available.'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItemDetailPage(item: item),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item['item_photo'] != null)
                              Container(
                                height: 150,
                                width: double.infinity,
                                child: Image.network(
                                  'http://192.168.31.218:3000/uploads/${item['item_photo']}',
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              const Icon(Icons.image, size: 150),
                            const SizedBox(height: 8.0),
                            Text(
                              item['item_name'] ?? 'No Name',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(item['item_price'] ?? 'No Price'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
