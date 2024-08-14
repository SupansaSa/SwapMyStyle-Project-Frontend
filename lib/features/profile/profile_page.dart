import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/features/profile/setting_page.dart';
import 'package:myapp/features/shop/add/add_home.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; 

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userId;
  String _username = 'Loading...';
  bool _loading = true;

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
      _fetchUserProfile();
    }
  }

  Future<void> _fetchUserProfile() async {
    final response = await http.get(Uri.parse('http://192.168.1.54:3000/getUserProfile?userId=$userId'));

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            _username = data['username'];
            _loading = false;
          });
        } else {
          setState(() {
            _username = 'Error fetching username';
            _loading = false;
          });
        }
      } catch (e) {
        print('Failed to parse JSON: $e');
        setState(() {
          _username = 'Error fetching username';
          _loading = false;
        });
      }
    } else {
      print('Failed to fetch user profile: ${response.statusCode}');
      setState(() {
        _username = 'Error fetching username';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE966A0),
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE966A0), Color(0xFFEDE4FF)],
              ),
            ),
            child: Center(
              child: _loading
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage('assets/image/user1.png'),
                        ),
                        SizedBox(height: 10),
                        Text(
                          _username,
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        const Text(
                          'ผู้ติดตาม:    กำลังติดตาม: ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(9.0),
              children: [
                ListTile(
                  leading: const Icon(Icons.list_alt_outlined),
                  iconColor: const Color(0xFFE966A0),
                  title: const Text('ประวัติการแลกเปลี่ยนของฉัน'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.shopping_bag_outlined),
                  iconColor: const Color(0xFFE966A0),
                  title: const Text('สินค้าของฉัน'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddHomePage()),
                      );
                    },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.favorite_border),
                  iconColor: const Color(0xFFE966A0),
                  title: const Text('สิ่งที่ฉันถูกใจ'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  iconColor: const Color(0xFFE966A0),
                  title: const Text('ดูล่าสุด'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.star_border),
                  iconColor: const Color(0xFFE966A0),
                  title: const Text('คะแนนของฉัน'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  iconColor: const Color(0xFFE966A0),
                  title: const Text('ศูนย์ช่วยเหลือ'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
