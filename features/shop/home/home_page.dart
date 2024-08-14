import 'package:flutter/material.dart';
import 'package:myapp/features/profile/profile_page.dart';
import 'package:myapp/features/shop/add/add_home.dart';
import 'package:myapp/features/shop/home/home_page_content.dart';
import 'package:myapp/features/shop/Search/search_page.dart';
import 'package:myapp/features/shop/swap/swap_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePageContent(),
    SearchPage(),
    const AddHomePage(), // Widget Placeholder สำหรับไอเท็มที่เหลือ
    const SwapPage(item: {},),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _selectedIndex == 0 // _selectedIndex == 0 ทำให้แสดงAppbar ของหน้า Homepage แค่หน้านี้ ถ้าจะให้แสดงหน้าอื่นด้วยให้ลบออก
          ? AppBar(
              backgroundColor: const Color(0xFFE966A0),
              automaticallyImplyLeading: false,
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 180,
                    height: 100,
                    decoration: const BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: DecorationImage(
                        image: AssetImage('assets/image/Logo2.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  color: Colors.white,
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.mail_outline),
                  color: Colors.white,
                  onPressed: () {},
                ),
              ],
              toolbarHeight: 80,
            )
          : null,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFE966A0),
        unselectedItemColor: Colors.grey[800],
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Swap',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
