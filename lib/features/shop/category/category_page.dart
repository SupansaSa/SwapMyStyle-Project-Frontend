import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:myapp/features/shop/add/item_detail_page.dart';
import 'package:myapp/screen/MyIP.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryPage extends StatefulWidget {
  final String category;

  const CategoryPage({Key? key, required this.category}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  MyIP myIP = MyIP();

  Future<void> _loadItems() async { 
  // ดึง userId จาก SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userIdString = prefs.getString('userId');

  // แปลง userId เป็น int
  int? userId = userIdString != null ? int.tryParse(userIdString) : null;

  final response = await http.get(Uri.parse('${myIP.domain}:3000/getItemsByType?itemType=${widget.category}&userId=$userId'));

  if (response.statusCode == 200) {
    try {
      final data = jsonDecode(response.body);
      if (data['success']) {
        final List<dynamic> items = data['items'];
        setState(() {
          _items = List<Map<String, dynamic>>.from(items);
        });
      } else {
        print(data['message']);
        setState(() {
          _items = [];
        });
      }
    } catch (e) {
      print('Failed to parse JSON: $e');
      setState(() {
        _items = [];
      });
    }
  } else {
    print('Failed to load items: ${response.statusCode}');
    setState(() {
      _items = [];
    });
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: const Color(0xFFE966A0),
        title: Text(
          widget.category,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: _items.isEmpty
          ? const Center(child: Text('ไม่มีสินค้าอยู่ในขณะนี้'))
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
                          builder: (context) => ItemDetailPage(
                            item: item,
                            currentUserId: '',
                          ),
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
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey[300],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Builder(
                                    builder: (context) {
                                      List<dynamic> itemPhotos = [];
                                      try {
                                        itemPhotos = json.decode(item['item_photo']);
                                      } catch (e) {
                                        print('Error decoding item photos: $e');
                                      }

                                      String imageUrl = itemPhotos.isNotEmpty
                                          ? '${myIP.domain}:3000/uploads/items/${itemPhotos[0]}'
                                          : '';

                                      return imageUrl.isNotEmpty
                                          ? Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                print('Error loading image: $error');
                                                return const Center(
                                                  child: Icon(Icons.image, size: 100),
                                                );
                                              },
                                            )
                                          : const Center(child: Icon(Icons.image, size: 100));
                                    },
                                  ),
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
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${item['item_price'].toString()}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
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
