import 'package:flutter/material.dart';

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE966A0), Color(0xFFEDE4FF)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 55,
                    width: double.infinity,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search in Store',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Color(0xFFE966A0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Color(0xFFE966A0), // สีขอบเมื่อไม่ได้โฟกัส
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Color(0xFFEDE4FF), // สีขอบเมื่อโฟกัส
                          ),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Popular Categories',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCategoryItem('assets/image/round-neck-shirt.png', 'เสื้อ', Colors.white, isSpecial: true),
                        _buildCategoryItem('assets/image/jeans.png', 'กางเกง', Colors.white, isSpecial: true),
                        _buildCategoryItem('assets/image/dress.png', 'เดรส', Colors.white, isSpecial: true),
                        _buildCategoryItem('assets/image/earrings.png', 'Jewelry', Colors.white, isSpecial: true),
                        _buildCategoryItem('assets/image/handbag.png', 'กระเป๋า', Colors.white, isSpecial: true),
                        _buildCategoryItem('assets/image/running-shoes.png', 'รองเท้า', Colors.white, isSpecial: true),
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
                    'Looking for the right style',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 230,
                    width: 400,
                    color: Colors.grey[300],
                    child: Image.asset(
                      'assets/image/trends.png',
                      fit: BoxFit.cover, // ปรับให้ภาพปรับตัวเองให้พอดีกับพื้นที่ Container
                    ),
                  ),
                  const SizedBox(height: 20),
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
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      return _buildProductItem();
                    },
                    itemCount: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String imagePath, String label, Color bgColor, {bool isSpecial = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0), // ปรับขนาดรูปที่อยู่ภายในตามต้องการ
              child: ClipOval(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain, // ใช้ BoxFit.contain เพื่อให้รูปภาพปรับขนาดให้พอดีกับพื้นที่ที่กำหนด
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: isSpecial ? Colors.black : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem() {
    return Stack(
      children: [
        Container(
          color: Colors.grey[300],
          child: const Center(child: Text('Product Image Placeholder')),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () {},
            ),
          ),
        ),
      ],
    );
  }
}
