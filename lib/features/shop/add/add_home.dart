import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/screen/MyIP.dart';
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

  MyIP myIP = MyIP();

  Future<void> _loadItems() async {
    if (userId == null) return;
    final response = await http.get(Uri.parse('${myIP.domain}:3000/getItems?userId=$userId'));

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        print('Received data: $data');
        final List<dynamic> items = data['items'];
        setState(() {
          _items = List<Map<String, dynamic>>.from(items);
        });
      } catch (e) {
        print('Failed to parse JSON: $e');
      }
    } else {
      print('Failed to load items: ${response.statusCode}');
    }
  }

  Future<void> _refreshItems() async {
    await _loadItems();
  }

  void _navigateToAddItemPage() async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const AddItemPage()),
  );

  if (result != null) {
    setState(() {
      _loadItems(); 
    });
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
      body: RefreshIndicator(
      onRefresh: _refreshItems,
      child: _items.isEmpty
          ? ListView(
              children: const [
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('No items available.'),
                  ),
                ),
              ],
            )
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

                    // Check if item_photo exists and parse it as a List
                    List<dynamic> itemPhotos = [];
                    if (item['item_photo'] != null) {
                      print('item_photo: ${item['item_photo']}');
                      try {
                        itemPhotos = json.decode(item['item_photo']);
                      } catch (e) {
                        print('Failed to decode item photos: $e');
                      }
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemDetailPage(
                              item: item,
                              currentUserId: userId!,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 150,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: itemPhotos.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.network(
                                              '${myIP.domain}:3000/uploads/items/${itemPhotos[0]}',
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : const Center(child: Icon(Icons.image, size: 100)),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
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
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
