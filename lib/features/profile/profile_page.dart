import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/features/authentication/signIn/sign_in_page.dart';
import 'package:myapp/features/profile/edit_profile_page.dart';
import 'package:myapp/features/profile/score_page.dart';
/*import 'package:myapp/features/profile/setting_page.dart';*/
import 'package:myapp/features/shop/add/add_home.dart';
import 'package:myapp/features/shop/swap/swap_page.dart';
import 'package:myapp/screen/MyIP.dart';
import 'package:myapp/widgets/custom_button.dart';
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
  String? _profilePhoto;
  bool _loading = true;
  int _creditPoints = 0; 
  int _discreditPoints = 0; 
  bool isLoading = false;

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

  MyIP myIP = MyIP();

 Future<void> _fetchUserProfile() async {
    final response = await http.get(Uri.parse('${myIP.domain}:3000/getUserProfile?userId=$userId'));

    if (response.statusCode == 200) {
      print(response.body); 
      try {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            _username = data['username'] ?? 'ไม่มีชื่อผู้ใช้';
            _profilePhoto = data['profile_photo'];
            _creditPoints = data['credit_points']; 
            _discreditPoints = data['discredit_points']; 
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

  Future<void> _navigateToEditProfile() async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const EditProfilePage()),
  );

  if (result == true) {
    _fetchUserProfile(); 
  }
}


  void _showFullImage(BuildContext context, String? imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            child: imageUrl != null
                ? Image.network(imageUrl)
                : const Image(image: AssetImage('assets/image/user1.png')),
          ),
        );
      },
    );
  }

  void _showLogoutConfirmation() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          'ออกจากระบบ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบบัญชีผู้ใช้ของคุณ?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'ยกเลิก',
              style: TextStyle(color: Colors.pink),
            ),
          ),
          TextButton(
            onPressed: () {
              _logout();
            },
            child: const Text(
              'ตกลง',
              style: TextStyle(color: Colors.pink),
            ),
          ),
        ],
      );
    },
  );
}


  Future<void> _logActivity(String activityName, String details) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    final response = await http.post(
      Uri.parse('${myIP.domain}:3000/logActivity'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'activityName': activityName,
        'details': details,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      print('Failed to log activity: ${response.statusCode}');
    }
  } catch (e) {
    print('Error logging activity: $e');
  }
}


  Future<void> _logout() async {
  setState(() {
    isLoading = true;
  });

  // Log the logout activity
  await _logActivity('logout', 'User logged out');

  // Proceed with logout
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('userId');
  
  setState(() {
    isLoading = false;
  });

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
    (route) => false,
  );
}

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE966A0),
        automaticallyImplyLeading: false,
        /*actions: [
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
        ],*/
      ),
      body: RefreshIndicator(
        onRefresh: _fetchUserProfile,
        child: Column(
          children: [
            Container(
              height: 165,
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
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _showFullImage(context, _profilePhoto);
                                  },
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundImage: _profilePhoto != null
                                        ? NetworkImage(_profilePhoto!)
                                        : const AssetImage('assets/image/user1.png') as ImageProvider,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _username,
                                        style: const TextStyle(
                                          fontSize: 25,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Credit: $_creditPoints',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Text(
                                            'Discredit: $_discreditPoints',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                                          side: const BorderSide(color: Colors.white, width: 1.5),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                        ),
                                        onPressed: _navigateToEditProfile,
                                        child: const Text(
                                          'แก้ไขโปรไฟล์',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(9.0),
                children: [
                  ListTile(
                    leading: const Icon(Icons.list_alt_outlined),
                    iconColor: const Color(0xFFE966A0),
                    title: const Text('ประวัติการแลกเปลี่ยนของฉัน'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SwapPage()),
                      );
                    },
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
                  /*const Divider(),
                  ListTile(
                    leading: const Icon(Icons.favorite_border),
                    iconColor: const Color(0xFFE966A0),
                    title: const Text('สิ่งที่ฉันถูกใจ'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),*/
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.star_border),
                    iconColor: const Color(0xFFE966A0),
                    title: const Text('คะแนนของฉัน'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScorePage(userId: userId!), // แทนที่ด้วย userId ที่แท้จริง
                      ),
                    );
                  },

                  ),
                  /*const Divider(),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    iconColor: const Color(0xFFE966A0),
                    title: const Text('ศูนย์ช่วยเหลือ'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),*/
                ],
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              height: 45,
              width: 350,
              child: CustomButton(
                title: 'ออกจากระบบ',
                onPressed: (BuildContext context) {
                  _showLogoutConfirmation();
                },
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}