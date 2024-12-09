import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/features/shop/add/item_detail_page.dart';
import 'dart:convert';
import 'package:myapp/features/shop/category/category_page.dart';
import 'package:myapp/screen/MyIP.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async'; 
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; 

class HomePageContent extends StatefulWidget {
final String userId;
  const HomePageContent({super.key, required this.userId});

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  List<Map<String, dynamic>> _items = []; // รายการสินค้าจะถูกดึงมาที่นี่
  List<Map<String, String>> _trends = [
    {'image': 'assets/image/trends.png'},
    {'image': 'assets/image/advert1.png'},
    {'image': 'assets/image/advert2.png'},
    {'image': 'assets/image/advert3.png'},
    {'image': 'assets/image/advert4.png'},
  ];

  final PageController _pageController = PageController();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _loadItems();
    _startAutoScroll();
  }
  
  MyIP myIP = MyIP();

    Future<void> _loadItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId'); // ดึง userId จาก SharedPreferences

    if (userId != null) {
      final response = await http.get(Uri.parse('${myIP.domain}:3000/getAllItems?userId=$userId'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _items = List<Map<String, dynamic>>.from(data['items']);
          });
        } else {
          print('Error: ${data['message']}');
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
  }

  Future<void> _refreshItems() async {
    await _loadItems();
  }

  void _toggleFavorite(int index) {
    setState(() {
      _items[index]['isFavorited'] = !(_items[index]['isFavorited'] ?? false);
    });
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        final int nextPage = (_pageController.page?.toInt() ?? 0) + 1;

        if (nextPage >= _trends.length) {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        } else {
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshItems,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      height: 230,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: Stack(
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            itemCount: _trends.length,
                            itemBuilder: (context, index) {
                              return Image.asset(
                                _trends[index]['image']!,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                          Positioned(
                            bottom: 10, 
                            left: 0,
                            right: 0,
                            child: Center(
                              child: SmoothPageIndicator(
                                controller: _pageController,
                                count: _trends.length,
                                effect: const ScaleEffect(
                                  dotHeight: 7,
                                  dotWidth: 7,
                                  activeDotColor: Colors.deepPurple,
                                  scale: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Categories',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 25),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCategoryItem(context, 'assets/image/round-neck-shirt.png', 'เสื้อ'),
                          _buildCategoryItem(context, 'assets/image/jeans.png', 'กางเกง'),
                          _buildCategoryItem(context, 'assets/image/dress.png', 'กระโปรง'),
                          _buildCategoryItem(context, 'assets/image/earrings.png', 'เครื่องประดับ'),
                          _buildCategoryItem(context, 'assets/image/handbag.png', 'กระเป๋า'),
                          _buildCategoryItem(context, 'assets/image/running-shoes.png', 'รองเท้า'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Popular Products',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return _buildProductItem(item, index);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String imagePath, String category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryPage(category: category),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10), 
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10), 
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover, 
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              category,
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> item, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailPage(item: item, currentUserId:'',),
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
            child: item['item_photo'] != null
                ? ClipRRect(
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
            /*Positioned(
              top: 8,
              right: 8,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: Icon(
                    (_items[index]['isFavorited'] ?? false) ? Icons.favorite : Icons.favorite_border,
                    color: (_items[index]['isFavorited'] ?? false) ? const Color(0xFFE966A0) : Colors.grey,
                  ),
                  onPressed: () {
                    _toggleFavorite(index);
                  },
                ),
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}
