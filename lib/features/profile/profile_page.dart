import 'package:flutter/material.dart';
import 'package:myapp/features/profile/setting_page.dart';
import 'package:myapp/features/shop/add/add_home.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/image/user1.png'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'username',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
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
