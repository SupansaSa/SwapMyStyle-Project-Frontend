import 'package:flutter/material.dart';
import 'package:myapp/features/chat/chat_history.page.dart';
import 'package:myapp/screen/MyIP.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/features/notifications/notification_page.dart';
import 'package:myapp/features/profile/profile_page.dart';
import 'package:myapp/features/shop/add/add_home.dart';
import 'package:myapp/features/shop/home/home_page_content.dart';
import 'package:myapp/features/shop/Search/search_page.dart';
import 'package:myapp/features/shop/swap/swap_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int _notificationCount = 0; 

  final List<Widget> _pages = [
    const HomePageContent(userId: '',),
    SearchPage(),
    const AddHomePage(),
    SwapPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchNotificationCount(); 
  }

  MyIP myIP = MyIP();

  Future<void> _fetchNotificationCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId'); 

    if (userId != null) {
      final url = Uri.parse('${myIP.domain}:3000/notifications/unread-count/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _notificationCount = data['unreadCount']; 
        });
      } else {
        // จัดการกรณีเกิดข้อผิดพลาด
        print('Failed to fetch notification count');
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _navigateToNotificationsPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId') ?? '';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationsPage(userId: userId),
      ),
    );

    
    setState(() {
      _notificationCount = 0;
      prefs.setInt('notificationCount', _notificationCount); 
    });
  }

  Future<void> _refreshData() async {
    
    await _fetchNotificationCount(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _selectedIndex == 0
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
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none),
                      color: Colors.white,
                      onPressed: _navigateToNotificationsPage,
                    ),
                    if (_notificationCount > 0) 
                      Positioned(
                        right: 1,
                        top: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.yellow[700],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Center(
                            child: Text(
                              '$_notificationCount',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.mail_outline),
                  color: Colors.white,
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    String? userId = prefs.getString('userId'); // ดึง userId จาก SharedPreferences

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatHistoryPage(userId: userId!), // ส่ง userId ไปยัง ChatHistoryPage
                      ),
                    );
                  },
                ),
              ],
              toolbarHeight: 80,
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _refreshData, 
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
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
