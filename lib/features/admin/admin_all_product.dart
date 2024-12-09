import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/screen/MyIP.dart';

class AdminAllProduct extends StatefulWidget {
  @override
  _AdminAllProductState createState() => _AdminAllProductState();
}

class _AdminAllProductState extends State<AdminAllProduct> {
  List items = [];
  final MyIP myIP = MyIP();

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    try {
      final response =
          await http.get(Uri.parse('${myIP.domain}:3000/getAllItemadmin'));

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          print('Received data: $data');

          // แปลงข้อมูล items ให้เป็น list ของ Map<String, dynamic>
          setState(() {
            items = List<Map<String, dynamic>>.from(data['items']);
          });
        } catch (e) {
          print('Failed to parse JSON: $e');
        }
      } else {
        print('Failed to load items: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ไม่สามารถโหลดสินค้าได้ กรุณาตรวจสอบการเชื่อมต่อ'),
        ),
      );
    }
  }

  Future<void> deleteItem(int itemId) async {
    print('Attempting to delete item with ID: $itemId'); // ตรวจสอบ itemId
    final response = await http.put(
      Uri.parse('${myIP.domain}:3000/adminDeleted/$itemId'),
      headers: <String, String>{'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      if (responseData['success'] == true) {
        // ไม่ต้องลบสินค้าจากรายการ items แต่ปรับปรุงสถานะ is_deleted
        setState(() {
          final itemIndex =
              items.indexWhere((item) => item['id'] == itemId);
          if (itemIndex != -1) {
            items[itemIndex]['is_deleted'] =
                true; // เปลี่ยนสถานะ is_deleted เป็น true
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ลบสินค้าสำเร็จแล้ว')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('การลบสินค้าไม่สำเร็จ: ${responseData['message']}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('การลบสินค้าไม่สำเร็จ: ${response.reasonPhrase}')),
      );
    }
  }

  Future<void> _refreshItems() async {
    await fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('รายการสินค้าทั้งหมด')),
      body: RefreshIndicator(
        onRefresh: _refreshItems,
        child: items.isEmpty
            ? const Center(child: Text('No items available.'))
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];

                      List<dynamic> itemPhotos = [];
                      if (item['item_photo'] != null) {
                        try {
                          itemPhotos = json.decode(item['item_photo']);
                        } catch (e) {
                          print('Failed to decode item photos: $e');
                        }
                      }

                      return GestureDetector(
                        child: Stack(
                          children: [
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (itemPhotos.isNotEmpty)
                                      Container(
                                        height: 150,
                                        width: double.infinity,
                                        child: Image.network(
                                          '${myIP.domain}:3000/uploads/items/${itemPhotos[0]}',
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    else
                                      const Icon(Icons.image, size: 150),
                                    const SizedBox(height: 8.0),
                                    Flexible(
                                      child: Text(
                                        item['item_name'] ?? 'No Name',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        '${item['item_price'].toString()}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[700],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await deleteItem(item['id']);
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
              ),
      ),
    );
  }
}